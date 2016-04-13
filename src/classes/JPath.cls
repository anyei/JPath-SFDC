/*
 * Author: Angel Robles
 * Created Date: 4/12/2016
 * Purpose : Use xpath type of expressions in order to select json nodes.
*/
public class JPath {
    string rawJson;    
   
    public JPath(string json){
        rawJson = json;
    }
    public object get(string xpath){
        return get(rawJson, xpath);
    }
    public static object get(string rawJson, string xpath){
        object result = null;
        Map<String, Object> rootMap = (Map<String, Object>) JSON.deserializeUntyped(rawJson);
        string processingPath = '';

        if(xpath.startsWith('/'))
            processingPath = xpath.removeStart('/');
        
        string toSearch =null;
        if(processingPath.contains('/')){
           toSearch= processingPath.substring(0,processingPath.indexOf('/'));
            
             system.debug('to search = '+ tosearch);
           
        processingPath = processingPath.substring(toSearch.length() + 1,processingPath.length());
        }
        else
            toSearch = processingPath;
        
        boolean applyPredicate = false;
        integer positionPredicate= 0;
        string toSearchToCompareBack = '';
        if (applyPredicate = (toSearch.contains('[') && toSearch.contains(']')) ){
            toSearchToCompareBack = toSearch;
             string toRemove = toSearch.substringBetween('[', ']');
            try{
                system.debug('to remove = '+ toremove);
                positionPredicate =integer.valueof(toRemove);
            }catch(Exception err){}
            
            toSearch = toSearch.remove('['+toRemove+']');
        }
       
        
        system.debug('nextPath = '+processingPath);
        
        object data = null;
        map<string,object> mapDeep = null;
        List<object> listDeep = null;
        
        if(rootMap.containsKey(toSearch)){
            data = rootMap.get(toSearch);
            if(applyPredicate && islist(data))
            {
                List<object> tmpd = (List<object>)data;
                if(tmpd.size() > 0 && positionPredicate > 0 && tmpd.size() >= positionPredicate)
                data = tmpd[positionPredicate - 1];
                else
                    data = null;
            }else if(applyPredicate)
            {
                data = null;
            }
        }
        
        system.debug('back ' + toSearchToCompareBack);
        system.debug('processing ' + processingPath);
        system.debug('data '+data);
        
        if( (!processingPath.contains('/') && (!processingPath.contains('[') && processingPath == toSearch ) ) || toSearchToCompareBack == processingPath ) 
            return data;
        
        system.debug(data);
        if(data != null)
        for(integer i =0;i<1000; i++){
            applyPredicate = false;
            positionPredicate = 0;
            
           if(isMap(data)){
               mapDeep = (Map<string,object>)data;
            	
               
               if(processingPath.contains('/')){
               toSearch = processingPath.substring(0,processingPath.indexOf('/'));
                   
               
        	   processingPath = processingPath.substring(toSearch.length()+1,processingPath.length() );
               }
               else
                   toSearch = processingPath;
               
               
               toSearchToCompareBack='';
               if (applyPredicate = (toSearch.contains('[') && toSearch.contains(']')) ){
            toSearchToCompareBack = toSearch;
             	string toRemove = toSearch.substringBetween('[', ']');
                    try{
                        system.debug('to remove = '+ toremove);
                        positionPredicate =integer.valueof(toRemove);
                    }catch(Exception err){}
                    
                    toSearch = toSearch.remove('['+toRemove+']');
                }
               
        	       system.debug(i+' to search = '+ tosearch);
               system.debug(i+' next path' + processingPath);
               
               if(mapDeep.containsKey(toSearch)){
                   data = mapDeep.get(toSearch);
                    system.debug(i+' to search entering = '+ tosearch);
               system.debug(i+' next path entering ' + processingPath);
                   
                   
                   if(applyPredicate && islist(data))
                    {
                        List<object> tmpd = (List<object>)data;
                        if(tmpd.size() > 0 && positionPredicate > 0 && tmpd.size() >= positionPredicate)
                        data = tmpd[positionPredicate - 1];
                        else 
                            data = null;
                        if(toSearchToCompareBack == processingPath)
                            return data;
                        
                    }else if(applyPredicate){
                        data = null;
                    }
                           
                           
                   if(toSearch == processingPath){
                       system.debug(' full result ' + data);
                       return data;
                       break;
                   }
                    
               }
               else{
                   system.debug('returning');
                   data = null;
                   system.debug(mapDeep);
                   return data;
                   break;
               }
            
               /*
               if(rootNode == null)
            	rootNode = new JNode(data,null);
               else if(i==1)
                   nextNode = new JNode(data,rootNode);
               else
                   nextNode */
           }
            else if(islist(data)){
               
               //system.assert(false,data);
           }  
            
            if(!ismap(data) && !islist(data)){
                data = null;
                system.debug('are you getting here?');
                return data;    
                break;
            }
        }
        return result;
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
    
}
