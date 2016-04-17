/*
 * Author: Angel Robles
 * Created Date: 4/12/2016
 * Purpose : Use xpath type of expressions in order to select json nodes.
*/
public class JPath {
    string rawJson;    
   
    //Constructor
    public JPath(string json){
        rawJson = json;
    }
    
    //Instance get method
    public object get(string xpath){
        return get(rawJson, xpath);
    }
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
		//attribute search or soemthing like that @name = "algo"
        /*for(integer i = 0;i<listData.size();i++){
            if(listData[i])
        }*/
        //
        if(context.applyPredicate){
            context.data = untypedObjectThatWeKnowIsAList;
            applyRootPredicateForList(context);
        }else{
            
            context.applyPredicate = false;
            context.positionPredicate = 0;
            
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
                    }
                }                
             
                
                system.debug('data found ' + tmpFoundObjects);
                system.debug('apply predicate '+context.ApplyPredicate);
                system.debug('predicate position '+ context.positionPredicate);
                
                if(tmpFoundObjects.size() > 0){
                    List<object> tmpR = new List<object>();
                    for(integer i  =0;i<tmpFoundObjects.size(); i ++){
                        context.data = tmpFoundObjects[i];
                        
                        if(context.applyPredicate)
                			applyRootPredicateForList(context);
                        
                        if(context.data != null)
                            tmpR.add(context.data);
                        
                    }
                    
                    if(context.applyPredicate != true)
                        context.foundPaths.add(context.toSearch);
                    if(tmpR.size() > 1)
                    context.data = tmpR;
                    else context.data = tmpR[0];
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
    static void applyRootPredicateForList(JPathContext context){
         List<object> tmpd = new list<object>();
        if(context.data instanceof list<object> ) {
            tmpd = (List<object>)context.data;
            system.debug('its a list for index calculation');
            system.debug('data ' + context.data);
            system.debug(tmpd.size());
            system.debug(tmpd[0]);
            system.debug(context.positionPredicate);
            
        }
        
        system.debug('search context apply predicate '+context.toSearch);
        
        string fpath ='';
        if(context.toSearch != context.predicateToSearch)//'['+context.positionPredicate+']')
            fpath = context.toSearch +context.predicateToSearch;//+ '['+context.positionPredicate+']';
        else fpath = context.predicateToSearch; //'['+context.positionPredicate+']';
        
        system.debug('fpath ' + fpath);
        
        //for now only index predicate is supported
        //the plan is to support more types of predicates
        if(tmpd.size() > 0 && context.positionPredicate > 0 && tmpd.size() >= context.positionPredicate){
            context.data = tmpd[context.positionPredicate - 1];
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
            
             string toRemove = context.toSearch.substringBetween('[', ']');             
             context.predicateToSearch = '['+toRemove+']';
            try{
               
                context.positionPredicate =integer.valueof(toRemove);
            }catch(Exception err){}
            
            context.toSearch = (startOrEnd == true ?  context.toSearch.removeStart('['+toRemove+']') :  context.toSearch.removeEnd('['+toRemove+']') ) ;
             
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
            
        }else if (isList(dataToWork)){            
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
    //static get method
    public static object get(string rawJson, string path){
        JPathContext context = new JPathContext(path);
        
        object untypedJson = JSON.deserializeUntyped(rawJson);  
        
        system.debug(context.data);
        if(context.targetPaths != null && context.targetPaths.size() > 0)
            for(integer i =1;i<1000; i++){  
                
                 system.debug('initial path = ' + context.processingPath);        
                system.debug('nextPath = '+context.toSearch);
                 
                compileQuery(context, ((i==1) ?untypedJson:null) );  
                
                system.debug('processing ' + context.processingPath);
                system.debug('data '+context.data);
                
                if(searchComplete(context,path) || context.targetPaths.size() <= i){
                    system.debug('break!');
                    system.debug('targetPaths '+ context.transPaths);
                    system.debug('i '+i);
                 break;
                    
                }
             
            } 
        
        return context.data;
    } 
    
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
        public object data;
        public string processingPath;
        public string toSearch;
		public string predicateToSearch;        
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
            applyPredicate = false;
            positionPredicate = 0;
        
        }
        
    }
    
}
