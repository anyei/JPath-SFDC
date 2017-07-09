/*
* Author: Angel Robles
* Created Date: 4/12/2016
* Purpose : Use xpath type of expressions in order to select json nodes.
*/
public class JPath {
    string rawJson;    
    
    /*
*PUBLIC CONSTRUCTOR 
*/
    public JPath(string json){
        rawJson = json;
    }
    
    /*
* PUBLIC INSTANCE METHODS
* 
*/
    public object get(string xpath){
        return get(rawJson, xpath);
    }
    
    /*
* PRIVATE HELPER METHODS
*
*/
    static boolean searchComplete(JPathContext context, string path){
        string sr = '';
        for(string s : context.foundPaths)                
            sr +='/'+ s;
        if(sr == '')
            context.data = null;
        system.debug(sr + ' and the path '+ path);
        return sr.removeStart('/') == path.removeStart('/');
    }
    static void processList(JPathCOntext context, object untypedObjectThatWeKnowIsAList){
        
        if(context.applyPredicate){
            context.data = untypedObjectThatWeKnowIsAList;
            applyRootPredicateForList(context);
        }else{
            
            context.applyPredicate = false;
            context.positionPredicate = 0;
            context.predicateTypeFound = '';
            
            //remove the predicate in case it has
            evalPredicate(context,false);
            
            system.debug('value to search starting with a name after removing the predicate ' +context.toSearch);
            
            List<object> tmpd = (list<object>)untypedObjectThatWeKnowIsAList;
            system.debug(tmpd + ' list of results ');
            if(tmpd.size() > 0) {
                object o =null;
                list<object> tmpFoundObjects = new list<object>();
                for(integer i =0;i<tmpd.size(); i++){
                    o = tmpd[i];
                    
                    system.debug(o + ' object to check ');
                    //looking for specific column values within the list items
                    if(ismap(o)){
                        system.debug('is a map ' + o);
                        Map<string,object> omap = (Map<string,object>)o;
                        
                        if(omap.containsKey(context.toSearch)){                            
                            
                            system.debug('found object by name in list '+omap.get(context.toSearch));
                            tmpFoundObjects.add(omap.get(context.toSearch));
                        }
                    }else if(islist(o)){
                        list<object> oListToCheck = (List<object>)o;
                        object secondO = null;
                        for(integer x=0;x<oListToCheck.size();x++){
                            secondO = oListToCheck[x];
                            if(ismap(secondO)){
                                Map<string,object> omap = (Map<string,object>)secondO;
                                if(omap.containsKey(context.toSearch)){
                                    system.debug('found match from list matching '+omap.get(context.toSearch));
                                    tmpFoundObjects.add(omap.get(context.toSearch));
                                }
                            }
                        }
                    }
                }                
                
                
                system.debug('data found ' + tmpFoundObjects);
                system.debug('apply predicate '+context.ApplyPredicate);
                system.debug('predicate position '+ context.positionPredicate);
                
                if(tmpFoundObjects.size() > 0){
                    List<object> tmpR = new List<object>();
                    for(integer i  =0;i<tmpFoundObjects.size(); i ++){
                        context.data = tmpFoundObjects[i];
                        
                        if(context.applyPredicate){
                            
                            applyRootPredicateForList(context);
                        }
                        if(context.data != null)
                            tmpR.add(context.data);
                        
                    }
                    
                    if(context.applyPredicate != true)
                        context.foundPaths.add(context.toSearch);
                    if(tmpR.size() > 1)
                        context.data = tmpR;
                    else if(tmpR.size() == 1) context.data = tmpR[0];
                    
                }else context.data = null;
                
            }
        }
        
        
    }
    static void processMap(JPathContext context, Map<string,object> mapData){
        system.debug('toSearch in processmap '+ context.toSearch);
        if(mapData.containsKey(context.toSearch)){
            
            context.data = mapData.get(context.toSearch);
            system.debug('applyPredicate ' + context.applyPredicate);
            system.debug('predicateToSearch ' + context.predicateToSearch);
            system.debug('prediate position ' + context.positionPredicate);
            if(context.applyPredicate)
            {               
                applyRootPredicateForList(context);                      
            }else
                context.foundPaths.add(context.toSearch);
        }else
            context.data = null;
    }
    
    /*
* TODO - THE FILTER SHOULD BE APPLIED HERE @name="angel"
* 
*/
    static void applyRootPredicateForList(JPathContext context){
        List<object> tmpd = new list<object>();
        if(context.data instanceof list<object> ) {
            tmpd = (List<object>)context.data;
            system.debug('its a list for index calculation');
            system.debug('data ' + context.data);
            system.debug(tmpd.size());
            system.debug(tmpd[0]);
            system.debug(context.positionPredicate);
            
            
        }else if(context.data instanceof map<string,object>){
            tmpd = new list<object> {context.data};
                }
        
        system.debug('search context apply predicate '+context.toSearch);
        
        string fpath ='';
        if(context.toSearch != context.predicateToSearch)//'['+context.positionPredicate+']')
            fpath = context.toSearch +context.predicateToSearch;//+ '['+context.positionPredicate+']';
        else fpath = context.predicateToSearch; //'['+context.positionPredicate+']';
        
        system.debug('fpath ' + fpath);
        
        CompositeSpecification specific = context.predicateRuleEvaluators.get(context.predicateTypeFound);
        
        //trying to be a little bit generic
        //specific should be either attribute or index specifications
        //one call to the IsSatisfiedBy method should be enough to determine if the records meets the conditions
        if(specific.IsSatisfiedBy(tmpd)){
            context.data = specific.getObjects();
            
            system.debug('data after getting index '+ context.data);       
            if(context.foundPaths.size() == 0)
                context.foundPaths.add(fpath); 
            else if(context.foundPaths.size() > 0 && context.foundPaths[context.foundPaths.size() - 1] != fpath)
                context.foundPaths.add(fpath); 
        }
        else{context.data = null;}
        
    }
    static void evalPredicate(JPathContext context, boolean startOrEnd){
        
        context.predicateToSearch = '';
        
        //if(context.toSearch == null)
        context.toSearch = context.processingPath;
        
        if ( context.applyPredicate = (context.toSearch.contains('[') && context.toSearch.contains(']') )  ){
            
            string rawPredicate = context.toSearch.substringBetween('[', ']');             
            context.predicateToSearch = '['+rawPredicate+']';
            system.debug('scope parser '+rawPredicate + ' '+context.predicateToSearch);
            
            CompositeSpecification indexSpecification = context.predicateRuleEvaluators.get('index').setPredicate(rawPredicate);
            CompositeSpecification atributeSpecification = context.predicateRuleEvaluators.get('attribute').setPredicate(rawPredicate);
            
            context.toSearch = (startOrEnd == true ?  context.toSearch.removeStart('['+rawPredicate+']') :  context.toSearch.removeEnd('['+rawPredicate+']') ) ;
            if(!indexSpecification.predicateMatch() && atributeSpecification.predicateMatch()){
                context.predicateTypeFound = 'attribute';
                string predicateDeep;
            }else if(indexSpecification.predicateMatch())
                context.predicateTypeFound = 'index';
            
        }
        
        system.debug('tosearch from evalpredicate '+ context.toSearch);
        
    }
    static void eval(JPathContext context, string pathToProcess, boolean isAList){
        
        context.applyPredicate = false;
        context.positionPredicate = 0;
        
        context.processingPath = pathToProcess;
        
        system.debug('processing from eval '+context.processingPath);
        if(context.processingPath.startsWith('[') && isAList==true)
            evalPredicate(context,true);
        else if(isAList != true)
            evalPredicate(context,false);
        
        /*if(context.processingPath.contains('/') ){
context.toSearch= context.processingPath.substring(0,context.processingPath.indexOf('/'));

system.debug('to search = '+ context.tosearch);

context.processingPath = context.processingPath.substring(context.toSearch.length() + 1,context.processingPath.length());
} 
else
context.toSearch = context.processingPath;*/
        
        
        
    }
    static void compileQuery(JPathContext context, object untypedJson){
        object dataToWork = (untypedJson == null) ? context.data : untypedJson;
        context.cleanSearches();
        if(isMap(dataToWork)){
            eval(context, context.popPath(), false);
            system.debug(context.transPaths);
            system.debug('target paths '+context.targetPaths);
            system.debug('is a map for the first time');
            system.debug('to search before removing the starting predicates '+context.toSearch);
            Map<String, Object> rootMap = (Map<String, Object>) dataToWork;
            processMap(context, rootMap);
            
        }
        else if (isList(dataToWork)){            
            eval(context, context.popPath(), true);
            system.debug(context.transPaths);
            system.debug('is a list for the first time');  
            system.debug('to search before removing the starting predicates '+context.toSearch);
            system.debug(context.foundPaths);
            string sr = '';
            for(string s : context.foundPaths)
                sr += s;
            system.debug(sr);
            processList(context, dataToWork);
        }
    }
    
    /*
* PUBLIC STATIC METHODS
*/
    public static object get(string rawJson, string path){
        JPathContext context = new JPathContext(path);
        
        object untypedJson = JSON.deserializeUntyped(rawJson);  
        
        system.debug(context.data);
        if(context.targetPaths != null && context.targetPaths.size() > 0)
            for(integer j =0;j<context.targetPaths.size(); j++){  
                
                system.debug('initial path = ' + context.processingPath);        
                system.debug('nextPath = '+context.toSearch);
                
                compileQuery(context, ((j==0) ?untypedJson:null) );  
                
                system.debug('processing ' + context.processingPath);
                system.debug('data '+context.data);
                
                if(searchComplete(context,path)){
                    system.debug('break!');
                    system.debug('targetPaths '+ context.transPaths);
                    system.debug('i '+j);
                    break;
                    
                }
                
            } 
        
        return context.data;
    } 
    
    
    /*
* PUBLIC HELPERS
*/
    public static boolean isMap(object o){
        return o instanceof map<string,object>;
    }
    public static boolean isList(object o){
        return o instanceof list<object>;
    }
    
    
    class JNode {
        public object data;
        public JNode parent;
        public JNode (object d, JNode ancestor){
            data = d; parent = ancestor;
        }
    }
    
    class JPathContext{
        public list<string> targetPaths;
        public list<string> transPaths;
        public list<string> foundPaths;
        public map<string,CompositeSpecification> predicateRuleEvaluators;
        public object data;
        public string processingPath;
        public string toSearch;
        public string predicateToSearch; 
        public string predicateTypeFound;
        public boolean applyPredicate;
        public integer positionPredicate;
        
        public JPathContext(){}
        public JPathContext(string path){
            if(path != null )
                targetPaths = path.split('/');
            
            if(targetPaths.size() <= 0)
                targetPaths.add(path);
            else if(targetPaths.size() > 1 && targetPaths[0] == '')
                targetPaths.remove(0);
            
            transPaths = targetPaths.clone();
            foundPaths = new list<string>();
            predicateRuleEvaluators = new map<string,CompositeSpecification> {
                'index' => new IndexPredicateSpecification(''),
                    'attribute' => new AttributePredicateSpecification('')
                    };
                        data = null;
            processingPath = '';
            toSearch = null;
            applyPredicate = false;
            positionPredicate = 0;
            
            
        }
        public string popPath(){
            string result = null;
            if(transPaths != null && transPaths.size() > 0)
            {
                system.debug('target paths ' + targetPaths);
                system.debug('trans paths ' + transPaths);
                
                result = transPaths.remove(0);
                
                system.debug('poppath '+ result);
                system.debug('trans paths '+transPaths);
                system.debug('target paths ' + targetPaths);
            } 
            return result;
            
        }
        public void cleanSearches(){
            processingPath = '';
            toSearch = null;
            predicateToSearch = '';   
            predicateTypeFound = '';
            applyPredicate = false;
            positionPredicate = 0;
            
        }
        
    }
    
    
    
    public virtual interface ISpecification
    {
        boolean IsSatisfiedBy(object o);
        object getObjects();
        boolean predicateMatch();
        ISpecification AndS(ISpecification specification);
        ISpecification OrS(ISpecification specification);
        ISpecification NotS(ISpecification specification);
        
    }
    
    public virtual interface IExpressionCompilator{
        boolean compile(object o, string logicalOperator);
    }
    public virtual interface ISupportedOperator{
        string GetOperatorStr();
        boolean Eval(object leftSide,object rightSide);
    }
    
    public virtual class SupportedOPerator implements ISupportedOPerator{
        public string stringVal(object o){
            return string.valueof(o);
        }
        public integer intVal(object o)
        {
            return integer.valueof(o);
        }
        public decimal decVal(object o){
            string strO = string.valueof(o);
            return decimal.valueof(strO);
        }
        public boolean boolVal(object o){
            return boolean.valueof(o);
        }
        public boolean isString(object o){
            return o instanceof string;
        }
        public boolean isBool(object o){
            return o instanceof boolean;
        }
        public boolean isInteger(object o){
            return o instanceof integer;
        }
        public boolean isDecimal(object o){
            return o instanceof decimal;
        }
        public boolean isId(object o){
            return o instanceof Id;
        }
        
        public virtual string GetOperatorStr(){
            return null;
        }
        public virtual boolean Eval(object leftSide, object rightSide){
            return false;
        }
    }
    
    
    
    public virtual class CompositeSpecification implements ISpecification
    {
        string rawPredicate;
        public CompositeSpecification(){}
        public CompositeSpecification(string predicate){
            this.rawPredicate = predicate;
        }
        
        public virtual boolean IsSatisfiedBy(object o){
            return false;
        }         
        public virtual CompositeSpecification setPredicate(string predicate){
            this.rawPredicate = predicate;
            return this;
        }
        public virtual object getObjects(){
            return null;
        }
        public virtual boolean predicateMatch(){
            return false;
        }
        
        
        public ISpecification AndS(ISpecification specification)
        {
            return new AndSpecification(this, specification);
        }
        
        public ISpecification OrS(ISpecification specification)
        {
            return new OrSpecification(this, specification);
        }
        
        public ISpecification NotS(ISpecification specification)
        {
            return new NotSpecification(specification);
        }
        
        
    }
    
    class IndexPredicateSpecification extends CompositeSpecification{
        integer index;
        object resultingObject;
        public IndexPredicateSpecification(string predicate){
            super(predicate);
            setIndex();
            
        }
        public override boolean IsSatisfiedBy(object record){
            list<object> records = (list<object>)record;
            resultingObject = null;
            
            if(index > 0 && records.size() > 0 && records.size() >= index  )
                resultingObject =  records[index - 1];
            return resultingObject != null;
        }
        public override object getObjects(){
            return resultingObject;
        }
        public override CompositeSpecification setPredicate(string predicate){
            this.rawPredicate = predicate;
            setIndex();
            return this;
        }
        public override boolean predicateMatch()
        {
            return index > -1;
        }
        void setIndex(){
            index  = -1;
            try{
                index=integer.valueof(this.rawPredicate);
            }catch(Exception e)
            {}
        }
    }
    
    public class AttributePredicateSpecification extends CompositeSpecification{  
        
        integer index;
        RecordsFilter filter;
        List<object> filteredObjects;
        public AttributePredicateSpecification(string predicate){
            super(predicate);
            setIndex();
            //filter = new RecordsFilter(predicate);
            
        }
        public override boolean IsSatisfiedBy(object record){
            list<object> records = (list<object>)record;
            filteredObjects = filter.filter(records);
            return filteredObjects.size() > 0;
        }
        public override CompositeSpecification setPredicate(string predicate){
            this.rawPredicate = predicate;
            setIndex();
            system.debug(' scope parser attribute predicate specification '+predicate);
            filter = new RecordsFilter(predicate);
            return this;
        } 
        
        public override boolean predicateMatch(){
            return index == null ||  index < 0;
        }
        public override object getObjects(){
            return filteredObjects;
        }
        
        void setIndex(){
            index  = null;
            try{
                index=integer.valueof(this.rawPredicate);
            }catch(Exception e)
            {}
        }
        
    }
    
    
    public class AndSpecification extends CompositeSpecification
    {
        ISpecification leftSpecification;
        ISpecification rightSpecification;
        
        public AndSpecification(ISpecification left, ISpecification right)
        {
            this.leftSpecification = left;
            this.rightSpecification = right;
        }
        
        public override boolean IsSatisfiedBy(object o)
        {
            return this.leftSpecification.IsSatisfiedBy(o)
                && this.rightSpecification.IsSatisfiedBy(o);
        }
    }
    
    public class OrSpecification extends CompositeSpecification
    {
        ISpecification leftSpecification;
        ISpecification rightSpecification;
        
        public OrSpecification(ISpecification left, ISpecification right)
        {
            this.leftSpecification = left;
            this.rightSpecification = right;
        }
        
        public override boolean IsSatisfiedBy(object o)
        {
            return this.leftSpecification.IsSatisfiedBy(o)
                || this.rightSpecification.IsSatisfiedBy(o);
        }
    }
    
    public class NotSpecification extends CompositeSpecification
    {
        ISpecification specification;
        
        
        public NotSpecification(ISpecification specification)
        {
            this.specification = specification;
            
        }
        
        public override boolean IsSatisfiedBy(object o)
        {
            return !this.specification.IsSatisfiedBy(o);
            
        }
    }
    
    public class EvaluationScopeDefinition {
        public EvaluationScopeDefinition ParentScope {get;set;}
        public string rawExpression {get;set;}
        public string operatorScope {get;set;}
        public boolean scopeOnly {get;set;}
        public boolean isOpen {get;set;}
        public List<ExpressionForMap> AndExpressions {get;set;}
        public List<ExpressionForMap> OrExpressions {get;set;}
        
        public List<EvaluationScopeDefinition>  MoreScopes {get;set;}
        public EvaluationScopeDefinition(){ scopeOnly = false; }
        public boolean EvaluateAllExpressions(object o){
            boolean andExpressionFlag;
            boolean orExpressionFlag;
            boolean innerScopesResult = MoreScopes.size() > 0;
            
            
            system.debug('scope evaluation '+rawExpression + ' operatorScope '+operatorScope +' scopeONly '+scopeOnly+' isopen '+isOpen + ' innerexpressiosn '+MoreScopes.size());
            
            if(!scopeOnly){
                
                //and expression evaluation, all ands should be true
                for(ExpressionForMap exp : andExpressions){               
                    andExpressionFlag = exp.compile(o, '&&');
                    system.debug('scope evaluation and expression evaluation = '+andExpressionFlag+ ' definition = '+exp.operations + ' '+o);
                    if(!andExpressionFlag)
                        break;
                }
                
                //or expression, only one or should be true           
                for(ExpressionForMap exp: orExpressions){
                    orExpressionFlag = exp.compile(o, '||');
                    system.debug('scope evaluation or  expression evaluation = '+orExpressionFlag+ ' definition = '+exp.operations+ ' '+o);
                    if(orExpressionFlag)
                        break;
                }
            }
            
            //all inner scopes should be true
            for(EvaluationScopeDefinition scope : MoreScopes){
                
               boolean result = scope.EvaluateAllExpressions(o);
                
                if(scope.operatorScope == '&&'){
                     innerScopesResult  =  innerScopesResult && result;
                    if(!innerScopesResult)breaK;
                }
                else if(scope.operatorScope == '||'){
                    innerScopesResult = innerScopesResult || result;
                    if(innerScopesResult == true)break;
                }else
                    innerScopesResult = result;
                /*if(scope.operatorScope == null || scope.scopeOnly == true)
                	innerScopesResult = scope.EvaluateAllExpressions(o);
                else if(scope.operatorScope == '&&'){
                    innerScopesResult = innerScopesResult && scope.EvaluateAllExpressions(o);
                    if(!innerScopesResult)breaK;
                }
                else if(scope.operatorScope == '||'){
                    innerScopesResult = innerScopesResult || scope.EvaluateAllExpressions(o);
                    if(innerScopesResult == true)break;
                }*/
                
            } 
            
            boolean orResult = (orExpressions.size() > 0 && orExpressionFlag);
            boolean andResult  = (andExpressions.size() > 0 && andExpressionFlag);
            boolean innerExpResult = (moreScopes.size() > 0 ? innerScopesResult : true);
            boolean finalResult = ( (scopeOnly == true) ? innerScopesResult :
                                    (orResult || (andResult  && innerExpResult))
                                  );
                                  // (operatorScope == null || operatorScope == '&&') ? (andResult && orResult ) : (operatorScope == '||' ? (andResult || orResult ) : false));
            system.debug(operatorScope+' scope inner scope evaluation = '+finalResult +' scope only '+scopeOnly+ ' final expression '+rawExpression+ ' object= '+o);
            return finalResult;
            
        }
    }
    
    public class ExpressionForMap implements IExpressionCompilator {
        map<string,SupportedOperator> supportedTokens;  
        public Map<string,List<map<string,object>>> operations;
        
        public ExpressionForMap(List<string> rawConditionsToEval, Map<string, SupportedOPerator> supportedTokens){
            this.rawConditions = rawConditionsToEval;
            this.operations = new Map<string,List<Map<string,object>>>();
            this.supportedTokens = supportedTokens;
            
            string leftSide;
            string rightSide;
            List<string> components;
            //do stuff to split by operator
            for(string s : rawConditions){
                for(string token : supportedTokens.keyset()){
                    
                    if(s.contains(token)){
                        components = s.split(token);
                        system.debug(components);
                        leftSide = components[0];
                        rightSide = components[1];
                        
                        leftside = trimStartQuote(leftside);
                        rightside = trimStartQuote(rightside);
                        if(!this.operations.containsKey(token)){
                            this.operations.put(token,new List<Map<string,object>>());
                        }
                        
                        /* if(leftSide.startsWith('"') || leftSide.startsWith('\'')){
if(leftSide.StartsWith('"'))
this.operations.get(token).add(new map<string,object> {rightSide => leftSide.removeEnd('"').removeStart('"')});
else
this.operations.get(token).add(new map<string,object> {rightSide => leftSide.removeEnd('\'').removeStart('\'')} );
}*/
                        /// else {
                        if(rightSide.StartsWith('"'))
                            this.operations.get(token).add(new map<string,object> {leftSide => rightSide.removeEnd('"').removeStart('"')});
                        else
                            this.operations.get(token).add(new map<string,object> {leftSide => rightSide.removeEnd('\'').removeStart('\'')} );
                        
                        //}
                        break;
                    }
                }
            }
        }
        
        
        public List<string> rawConditions {get;set;}
        public boolean compile(object o, string logicalOperator){
            
            List<object> recordsTOProcess = new List<object>();
            
            if(o instanceof map<string,object>)
                recordsToProcess.add(o);
            else if(o instanceof list<object>)
                recordsToProcess =(list<object>)o;
            
            boolean result =false;
            for(object ox : recordsToProcess){
                Map<string,object> mapRecord = new map<string,object>();
                if(ox instanceof map<string,object>)
                    mapRecord = (Map<string,object>)ox;
                
                for(string operator : operations.keyset()){
                    system.debug('operator '+ operator+ ' components '+operations.get(operator));
                    
                    for(Map<string,object> components : operations.get(operator)){
                        for(string attr : components.keySet()){
                            
                            //if the map contains the left side which i'm suposed its the attribute
                            if(result = mapRecord.containsKey(attr) ){
                                object v = mapRecord.get(attr); 
                                system.debug(' value = '+v + ' attr = '+attr+ ' component = '+components.get(attr));
                                result = supportedTokens.get(operator).Eval(v,components.get(attr));
                                if( (logicalOperator == '||' && result) || (logicalOperator=='&&' && !result))                                   
                                    break;
                            }else {break;}
                            
                        }
                        
                        if( (logicalOperator == '||' && result) || (logicalOperator=='&&' && !result))
                            break;
                    }
                    
                    if( (logicalOperator == '||' && result) || (logicalOperator=='&&' && !result))
                        break;
                }
                
            }
            
            
            system.debug('final result from the valuation = '+result);
            return result;
        }
        string trimStartQuote(string value){
            
            string result = '';
            integer doubleQuotes = value.indexof('"');
            integer simpleQuote = value.indexof('\'');
            if(doubleQuotes < 0 && simpleQuote < 0) return value.trim();
            
            if(doublequotes > -1 && ( doublequotes < simplequote || simplequote < 0))
                result = value.substring(doublequotes+1, value.length() - 1 );
            else if(simpleQuote > -1 &&  (simpleQuote < doubleQuotes || doublequotes < 0))
                result = value.substring(simplequote+1, value.length() - 1 );
            
            doubleQuotes = result.indexof('"');
            simpleQuote = result.indexof('\'');
            
            if(doublequotes > -1 && doublequotes > simplequote)
                result = result.substring(0, doublequotes );
            else if(simpleQuote > -1 && simpleQuote > doublequotes)
                result = result.substring(0,simpleQuote);
            return result;
        }
        
        
    }
    
    public class ScopeParser{
        public Set<EvaluationScopeDefinition> Scopes{get;set;}
        string rawPredicate;
        map<string, SupportedOperator> supportedTokens;
        public ScopeParser(string predicate ){
            Scopes = new set<EvaluationScopeDefinition>();
            system.debug('scope parser '+predicate);
            this.rawPredicate = predicate;
            this.supportedTokens = new map<string,SupportedOPerator> {
                '>='=> new GreaterThanEqualsOperator(),'<='=> new LessThanEqualsOperator(), '!=' => new NotEqualsOperator(),'=' => new EqualsOperator(),
                    '>' => new GreaterThanOperator(),'<' => new LessThanOperator()};
                        ParseExpressions(); 
            
        }
        public void ParseExpressions(){
            LIst<JPath.EvaluationScopeDefinition> OpenEvalScopes = new List<JPath.EvaluationScopeDefinition>();
            List<integer> openParenthesisIndexes = new List<integer>();
            
            //ROOT SCOPE EXPRESSION
            Jpath.EvaluationScopeDefinition resd = new Jpath.EvaluationScopeDefinition();
            resd.isOPen = true;
            resd.AndExpressions = new List<Jpath.ExpressionForMap>();
            resd.orExpressions = new List<JPath.ExpressionForMap>();
            resd.MoreScopes = new List<JPath.EvaluationScopeDefinition>();
            resd.rawExpression = rawPredicate;
            system.debug('scope parser '+resd.rawExpression);
            OpenEvalScopes.add(resd);
            
            integer openParenthesis = 0;
            integer closedParenthesis = 0;
            
            integer openParenthesisIndex = -1;
            integer lastClosedParenthesisIndex = -1;
            
            integer openDoubleQuoteIndex = -1;
            integer lastClosedDoubleQuoteIndex = -1;
            
            boolean openDoubleQuote = false;
            boolean lastClosedDoubleQuote = false;
            
            string strippedString = rawPredicate;
            for(integer i =0;i<rawPredicate.length(); i++){
                
                string leftChars = rawPredicate.substring(i,i+1);
                
                system.debug(leftChars);
                
                if(leftChars =='"' && !openDoubleQuote){
                    
                    openDoubleQuote = true;
                    lastClosedDoubleQuote = false;                         
                    
                    lastClosedDoubleQuoteIndex = -1;
                    openDoubleQuoteIndex = i;
                    
                    integer orPath = rawPredicate.substring(0,i).lastIndexOf('||');
                    integer andPath = rawPredicate.substring(0,i).lastIndexOf('&&');
                    if(orPath > andPath)
                        resd.operatorScope = '||';
                    else if(andPath > -1)
                        resd.operatorScope = '&&';
                    
                }
                else if(leftChars == '"' && openDoubleQuote ){
                    
                    lastClosedDoubleQuote = true;
                    
                    openDoubleQuote = false;
                    openDoubleQuoteIndex = -1;
                    
                    
                    lastClosedDoubleQuoteIndex = i;
                    
                    
                }
                else if( leftChars == '(' && !openDoubleQuote){
                    
                    openParenthesis += 1;
                    lastClosedParenthesisIndex = -1;                         
                    openParenthesisIndexes.add(i);
                    
                    Jpath.EvaluationScopeDefinition esd = new Jpath.EvaluationScopeDefinition();
                    esd.isOPen = true;
                    esd.AndExpressions = new List<Jpath.ExpressionForMap>();
                    esd.orExpressions = new List<JPath.ExpressionForMap>();
                    esd.MoreScopes = new List<JPath.EvaluationScopeDefinition>();
                    integer orPath = rawPredicate.substring(0,i).lastIndexOf('||');
                    integer andPath = rawPredicate.substring(0,i).lastIndexOf('&&');
                    if(orPath > andPath)
                        esd.operatorScope = '||';
                    else if(andPath > -1)
                        esd.operatorScope = '&&';
                    
                    if(OpenEvalScopes.size() > 0){
                        esd.parentScope = OpenEvalScopes[OpenEvalScopes.size() - 1];
                        esd.operatorScope = esd.parentScope.moreScopes.size() > 0 ? esd.operatorScope : null;
                        esd.parentScope.moreScopes.add(esd);
                    }
                    
                    OpenEvalScopes.add(esd);
                    
                }
                else if(leftChars ==')' && !openDoubleQuote){
                    
                    closedParenthesis += 1;
                    
                    
                    lastClosedParenthesisIndex = i;
                    JPath.EvaluationScopeDefinition lastOpenScope = OpenEvalScopes.remove(OpenEvalScopes.size() - 1);
                    lastOPenScope.isOpen = false;
                    
                    integer lastOPenParenthesis = openParenthesisIndexes.remove(openParenthesisIndexes.size() - 1);
                    string expression = rawPredicate.substring(lastOPenParenthesis,lastClosedParenthesisIndex+1);
                    lastOPenScope.rawExpression = expression;
                    system.debug(' scope parser '+ expression);
                    
                    BuildExpressionMap(expression, lastOpenScope);
                    
                }
                
            }
            
            
            BuildExpressionMap(rawPredicate,resd);
            
            scopes.add(resd);
            system.debug(' scope parser scopes total '+scopes);
        }
        
        public void BuildExpressionMap(string expression, EvaluationScopeDefinition lastOpenScope){
            List<string> separatedAndExp = new List<string>();
            List<string> separatedOrExp = new List<string>();
            system.debug('scope parser full expre  ' + lastOpenScope.rawExpression);
            for(EvaluationScopeDefinition innerScope : lastOpenScope.moreScopes){
                system.debug(' scope parser inner scope to remove '+innerScope.rawExpression);
                system.debug('expression is '+expression);
                expression = expression.remove(innerScope.rawExpression);
                system.debug('expression result is '+expression);
                
            }
            
            
            //maybe the fix is here.. we just need to add an additional flag
            //to the scope saying that it is just an scope and it has inner scopes in
            //
            //also when splitting by && or || we might need to do some tricks.. replace the && or the || with special chars so we can do splits wihtout
            //any issue
            if(expression.contains('&&')){
                
                List<string> splited = expression.trim().split('&&');
                system.debug('scope parser && '+splited);
                for(string s : splited){                                
                    
                    if(s.contains('||')){
                        List<string> sp2 = s.trim().split('\\|\\|');
                        
                        //the firts one should be an and
                        separatedAndExp.add(sp2.remove(0).trim().removeStart('(').removeEnd(')'));
                        
                        separatedOrExp.addall(sp2);
                    }else
                    { separatedAndExp.add(s.trim().removeStart('(').removeEnd(')'));  }
                }
                
                
            }
            else if(expression.contains('||')){                
                List<string> splited = expression.trim().split('\\|\\|');
                system.debug('scope parser || ' +splited);
                for(string s : splited){
                    if(s.contains('&&')){
                        List<string> sp2 = s.trim().split('&&');
                        
                        //the first one should be an or
                        separatedOrExp.add(sp2.remove(0).trim().removeStart('(').removeEnd(')'));
                        separatedAndExp.addall(sp2);
                    }else
                    {  separatedOrExp.add(s.trim().removeStart('(').removeEnd(')')); }
                } 
            }
            
            lastOpenScope.scopeOnly = (expression.length() > 0 && isScopeOnly(expression)  ) || (expression.length() == 0 && lastOpenScope.MoreScopes.size() > 0);
            if(separatedAndExp.size() > 0 && lastOpenScope.scopeOnly != true ){
                lastOpenScope.AndExpressions.add(new ExpressionForMap(separatedAndExp, supportedTokens));
                system.debug('scope parser size of separated and exp ' + separatedAndExp.size() + ' '+separatedAndExp);
            }
            if(separatedOrExp.size() > 0 && lastOpenScope.scopeOnly != true){
                lastOpenScope.OrExpressions.add(new ExpressionForMap(separatedOrExp, supportedTokens));
                system.debug('scope parser size of separated or exp ' + separatedOrExp.size() + ' '+separatedOrExp);
            }
            
            if(separatedAndExp.size() <= 0 && separatedOrExp.size() <= 0 && lastOpenScope.scopeOnly != true ){
                lastOpenScope.AndExpressions.add(new ExpressionForMap(new list<string> {expression.remove('(').remove(')')}, supportedTokens));
                system.debug(lastOpenScope.MoreScopes.size() + ' scope parser size of expression and exp ' + expression);
            }
            
            //lastOpenScope.operatorScope = lastOpenScope.operatorScope == null ? '&&' : lastOpenScope.operatorScope;
            
            system.debug(lastOpenScope.operatorScope+'scope parser separated and, or '+lastOpenScope.AndExpressions + ' ' +lastOpenScope.OrExpressions + ' full expre '+ expression + ' scope only '+ lastOpenScope.scopeOnly);
            
            
        }
        boolean isScopeOnly(string expression){
            string toTest = expression.replace(' ','');
            boolean result = false;
            set<string> scopeOnlyDef = new set<string>{'(',')','&','|'};
                for(integer i =0;i<toTest.length();i++){
                    result =  scopeOnlyDef.contains(toTest.substring(i,i+1));
                    
                    if(!result) { system.debug('break ' +toTest.substring(i,i+1)); break; }
                    
                }
            system.debug('is scope only evaluation  size '+ expression.length() +' ' + result +' ' + toTest);
            return result;
        }
        
        
    }    
    public class EqualsOPerator extends SupportedOPerator{
        public string OperatorStr {get;set;}
        public EqualsOperator(){
            this.OPeratorStr = '=';
        }
        public override boolean Eval(object leftSide, object rightSide){
            system.debug(' left side = ' + leftSide + ' right side = '+ rightside + ' '+ (leftside==rightside) );
            return leftSide == rightSide;
        }
        public override string getOperatorStr(){
            return this.OperatorStr;
        }
    }
    public class NotEqualsOPerator extends SupportedOPerator{
        public string OperatorStr {get;set;}
        public NotEqualsOPerator(){
            this.OPeratorStr = '!=';
        }
        public override boolean Eval(object leftSide, object rightSide){
            return !(leftSide == rightSide);
        }
        public override string getOperatorStr(){
            return this.OperatorStr;
        }
    }
    public class GreaterThanEqualsOPerator extends SupportedOPerator{
        public string OperatorStr {get;set;}
        public GreaterThanEqualsOPerator(){
            this.OPeratorStr = '>=';
        }
        public override boolean Eval(object leftSide, object rightSide){
            if(isInteger(leftSide) && isInteger(rightSide)){                
                return intVal(leftSide)>=intVal(rightSide);          
            }else if(isString(leftside) && isString(rightSide)){
                return stringVal(leftSide) >= stringVal(rightSide);
            }else if(isDecimal(leftSide) && isDecimal(rightSide)){
                return decVal(leftSide) >= decVal(rightSide);
            }
            
            return false;            
        }
        public override string getOperatorStr(){
            return this.OperatorStr;
        }
    }
    public class LessThanEqualsOPerator extends SupportedOPerator{
        public string OperatorStr {get;set;}
        public LessThanEqualsOPerator(){
            this.OPeratorStr = '<=';
        }
        public override boolean Eval(object leftSide, object rightSide){
            if(isInteger(leftSide) && isInteger(rightSide)){                
                return intVal(leftSide)<=intVal(rightSide);          
            }else if(isString(leftside) && isString(rightSide)){
                return stringVal(leftSide) <= stringVal(rightSide);
            }else if(isDecimal(leftSide) && isDecimal(rightSide)){
                return decVal(leftSide) <= decVal(rightSide);
            }
            return false;
        }
        public override string getOperatorStr(){
            return this.OperatorStr;
        }
    }    
    public class GreaterThanOPerator extends SupportedOPerator{
        public string OperatorStr {get;set;}
        public GreaterThanOPerator(){
            this.OPeratorStr = '>';
        }
        public override boolean Eval(object leftSide, object rightSide){
            if(isInteger(leftSide) && isInteger(rightSide)){                
                return intVal(leftSide)>intVal(rightSide);          
            }else if(isString(leftside) && isString(rightSide)){
                return stringVal(leftSide) > stringVal(rightSide);
            }else if(isDecimal(leftSide) && isDecimal(rightSide)){
                return decVal(leftSide) > decVal(rightSide);
            }
            return false;
        }
        public override string getOperatorStr(){
            return this.OperatorStr;
        }
    }
    public class LessThanOPerator extends SupportedOPerator{
        public string OperatorStr {get;set;}
        public LessThanOPerator(){
            this.OPeratorStr = '<';
        }
        public override boolean Eval(object leftSide, object rightSide){
            if(isInteger(leftSide) && isInteger(rightSide)){                
                return intVal(leftSide) < intVal(rightSide);          
            }else if(isString(leftside) && isString(rightSide)){
                return stringVal(leftSide) < stringVal(rightSide);
            }else if(isDecimal(leftSide) && isDecimal(rightSide)){
                return decVal(leftSide) < decVal(rightSide);
            }
            return false;
        }
        public override string getOperatorStr(){
            return this.OperatorStr;
        }
    }
    
    public class RecordsFilter{
        
        public set<EvaluationScopeDefinition> scopes;
        public RecordsFilter(string  conditionalExpression){
            system.debug('scope parser '+conditionalExpression);
            //expression parser
            ScopeParser parser = new ScopeParser(conditionalExpression);
            scopes = parser.Scopes;
        }
        public List<Object> Filter(List<object> records){
            boolean passValidation = false;
            List<object> result = new List<object>();
            ///TODO
            //IMPLEMENT THE ACTION TO EVALUATE WHICH RECORDS MEETS THE CONDITION
            for(object o : records){
                passValidation = false;
                for(EvaluationScopeDefinition evalScope : scopes){
                    
                    passValidation = evalScope.EvaluateAllExpressions(o);
                    system.debug(scopes.size() +'scope evaluation = '+passValidation+ ' object = '+o);
                    //if(!passValidation)
                      //  break;
                    
                }
                if(passValidation){
                    system.debug('scope evaluation pass validation ' + o);
                    result.add(o);
                }else{
                    system.debug('scope evaluation didnt pass validation ' + o);
                }
            }
            
            
            return result;
        }
        
    }
}