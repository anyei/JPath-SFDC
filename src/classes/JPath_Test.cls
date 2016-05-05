/*
 * Author : Angel Robles
 * Apex Class Tested: JPath
 * Purpose: Unit testing for JPath apex class. Should contain all the supported scenarios.
 * 
 * */
@IsTest
public class JPath_Test {
    
     @IsTest
      public static void SelectMultipleInstancePropertyWithPredicateAndRootArrayInstance(){
          string rawJson = '[{"results":{"aField":"aValuedkdk"}}, {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple","Red Apple","yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"results":[{"aFieldx":"Avalue1","aField2":"Avalue2","aField3":"Avalue3"},{"aField1":"Avalue1","aField2":"Avalue2"},{"aField1":"Avalue1","aField":"Avalue2","aField3":"Avalue3"},{"aField1":"Avalue1","aField2":"Avalue2","aField3":"Avalue3"},{"aField1":"Avalue1","aField2":"Avalue2","aField3":"Avalue3"}]},{"third":"objectx"} ]';
        
          JPath jpathExec = new JPath(rawJson);
          
          object records = jpathExec.get('/results[aField1="Avalue1" && aField2="Avalue2" && aField3="Avalue3"]');
      
          system.assert(records instanceof List<object>,'should be a list ' + records);
      
          List<object> resultsx = (List<object>)records;
          List<Map<string,object>> results = new List<Map<string,object>>();
          for(object o : resultsx){
              if(o instanceof  map<string,object>)
                  results.add((map<string,object>)o);
          }
          
          system.assert(results != null && results.size() == 2 && results[0].get('aField1') == 'Avalue1' && results[1].get('aField2') == 'Avalue2' ,'Should bring 2 result ' + results + ' '+ results.size());
          
          
    }
    
    @IsTest
      public static void SelectMultipleInstancePropertyWithPredicateRootArrayInstance(){
          string rawJson = '[{"results":{"aField":"aValuedkdk"}}, {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple","Red Apple","yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"results":[{"aField":"Avalue1"},{"aField":"Avalue2"},{"aField":"Avalue3"}]},{"third":"objectx"} ]';
        
          JPath jpathExec = new JPath(rawJson);
          
          object result = jpathExec.get('/results[aField="Avalue2" || aField="Avalue3"]/aField');
      
          system.assert(result instanceof List<object>,'should be a list ' + result);
      
          List<object> results = (List<object>)result;
          
          system.assert(results != null && results.size() == 2 && results[0] == 'Avalue2' && results[1] == 'Avalue3' ,'Should bring 2 result ' + results + ' '+ results.size());
          
          
    }
    
    
    
  @IsTest
    public static void SelectSingleObjectRecordRootArray(){
         string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple",[1,2,5,4],"yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
          JPath jpathExec = new JPath(rawJson);
          
          object result = jpathExec.get('/results[aField="Avalue"]');
      
          system.assert(result instanceof list<object>,'should be list ' + result);
        
          List<object> results = (List<object>) result;
          
          system.assert(results != null && results.size() ==1 ,'Should bring 1 result ' + results);
    }

    @IsTest
      public static void SelectMultipleInstancePropertyMultiplePredicateRootObjectInstance(){
          string rawJson = ' {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple",[1,2,5,4],"yellow apple"]}] }';
          
          JPath jpathExec = new JPath(rawJson);
          
          object result = jpathExec.get('/results');
      
          system.assert(result instanceof List<object>,'should be a list ' + result);
          
          List<object> results = (List<Object>)result;
          
          system.assert(results != null && results.size() == 3,'Should bring 3 result ' + results);
          
          
    }
    
    
     @IsTest
      public static void SelectMultipleInstancePropertyMultiplePredicateRootArrayInstance(){
          string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple",[1,2,5,4],"yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
          JPath jpathExec = new JPath(rawJson);
          
          object result = jpathExec.get('/results/listOfFruits[3]/[3]');
      
          system.assert(result instanceof integer,'should be an integer ' + result);
          
          system.assert(result != null && integer.valueof(result) == 5,'Should bring 1 result ' + result);
          
          
    }
  
    
      
    @IsTest
      public static void SelectMultipleInstancePropertyNoPredicateRootArrayInstance(){
          string rawJson = '[{"results":{"aField":"aValuedkdk"}}, {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple","Red Apple","yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"results":[{"aField":"Avalue1"},{"aField":"Avalue2"},{"aField":"Avalue3"}]},{"third":"objectx"} ]';
        
          JPath jpathExec = new JPath(rawJson);
          
          object result = jpathExec.get('/results/aField');
      
          system.assert(result instanceof List<object>,'should be a list ' + result);
      
          List<object> results = (List<object>)result;
          
          system.assert(results != null && results.size() == 6 && results[0] == 'aValuedkdk' && results[1] == 'AValue'  && results[5] == 'Avalue3','Should bring 6 result ' + results + ' '+ results.size());
          
          
    }
    
    
    @IsTest
      public static void SelectMultiplePropertyNoPredicateRootArray(){
          string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple","Red Apple","yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
          object result = JPath.get(rawJson, '/results/aField');
      
          system.assert(result instanceof List<object>,'should be a list ' + result);
      
          List<object> results = (List<object>)result;
          
        system.assert(results != null && results.size() == 2 && results[1] == 'aValued' ,'Should bring 2 result ' + results + ' '+ results.size());
          
          
    }
    
     @IsTest
      public static void SelectSinglePropertyPredicateIndexRootArray(){
          string rawJson = '[{"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple","Red Apple","yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
        object result = JPath.get(rawJson, '/results/listOfFruits[2]');
      
          system.assert(result instanceof string,'should be a string ' + result);
      
        system.assert(result != null && result == 'green apple' ,'Should bring 1 result ' + result);
          
          
    }
    
     @IsTest
      public static void SelectSingleElementByUsingPredicateIndexesInEveryPathArray(){
          string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple","Red Apple","yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
        object result = JPath.get(rawJson, '/results[3]/listOfFruits[2]');
      
          system.assert(result instanceof string,'should be a string');
          
        system.assert(result != null && result == 'green apple' ,'Should bring 1 result ' + result );
          
          
    }
    
    
    @IsTest
      public static void SelectSingleElementUsingIndexPredicateOnePathRootArray(){
          string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"aField":"moreValues"}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
        object result = JPath.get(rawJson, '/results[3]');
          
          system.assert(result instanceof map<string,object>,'should be a map');
          
          map<string,object> finalResult = (map<string,object>) result;
          
        system.assert(finalResult != null && finalResult.size() == 1 && finalResult.containsKey('aField') && finalResult.get('aField') == 'moreValues' ,'Should bring 1 result ' + finalResult + ' '+ finalResult.size());
          
          
    }
    
    
     
     @IsTest
      public static void SelectMultipleElementsOnePathNoPredicateRootArray(){
         string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
         object result = JPath.get(rawJson, '/results');
      
         system.assert(result instanceof List<object>,'should be a list');
      
         List<object> results = (List<object>)result;
          
         system.assert(results != null && results.size() == 2 ,'Should bring 2 results '+ results.size());
          
          
    }
    
    
     
    @IsTest
      public static void MultipleElementsUsingAttributeNamePredicateRootIsAList(){
          string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
        object result = JPath.get(rawJson, '/second');
      
        system.assert(result instanceof List<object>,'should be a list');
      
          List<object> results = (List<object>)result;
        system.assert(results != null && results.size() == 4 ,'Should bring 4 results');
          
          
    } 
   
 
    @IsTest
      public static void SelectSingleElementUsingAttributeNamePredicateRootIsAList(){
          string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}},{"second":"object"},{"third":"objectx"} ]';
        
        object result = JPath.get(rawJson, '/second');
      
        system.assert(result instanceof string,'should be a string');
      
        system.assert(result != null && result == 'object','Should bring "object" as result');
          
          
    }
   
  @IsTest
      public static void SelectSingleElementUsingIndexPredicateRootIsAList(){
          string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}},{"second":"object"},{"third":"object"} ]';
        
        object result = JPath.get(rawJson, '/[2]');
      
        system.assert(result instanceof map<string,object>,'should be a map');
        
        map<string,object> resultingObject = (map<string,object>)result;  
          
        system.assert(resultingObject != null && resultingObject.containsKey('second') && resultingObject.get('second') == 'object','Should bring second item from the root array');
    }   
    @IsTest
    public static void SelectSingleElementFromTheRootReturnsIt(){
        string rawJson = '{"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}}';
        
        object result = JPath.get(rawJson, '/results');
        
        system.assert(result != null,'Should bring something');
    }
   
    @IsTest
    public static void SelectSingleElementSecondInTheRootReturnsIt(){
		string rawJson = '{"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}}';

        object result = JPath.get(rawJson, '/another');
       
        system.assert(result instanceof map<string,object>,'should be a map');
            
        Map<string,object> resultFromAnother = (Map<string,object>)result;
        
        system.assert(resultFromAnother != null && resultFromAnother.containsKey('somef') && resultFromAnother.get('somef') == 'somed','Should have brough "another" json element');
        
    }
    @IsTest
    public static void SelectSingleElementChildOfARootReturnsIt(){
        object result = JPath.get('{"results":{"SecondResults":{"thirdResult":{"aFieldx":"aValueY"}}},"more":{"aField":"Avalue"},"another":{"somef":"somed"}}', '/results/SecondResults/thirdResult');
       
        system.assert(result instanceof map<string,object>,'should be a map');
            
        Map<string,object> resultFromAnother = (Map<string,object>)result;
        
        system.assert(resultFromAnother != null && resultFromAnother.containsKey('aFieldx') && resultFromAnother.get('aFieldx') == 'aValueY','Should have brough "thirdResult" json element');
        
    }
    
    @IsTest
    public static void SelectMultipleElementsChildOfARootReturnsThem(){
        object result = JPath.get('{"results":{"SecondResults":{"thirdResult":[{"somex":"somey"},{"somex":"somey"},{"somex":"somey"},{"somex":"somey"}]}},"more":{"aField":"Avalue"},"another":{"somef":"somed"}}', '/results/SecondResults/thirdResult');
       
        system.assert(result instanceof list<object>,'should be a list');
            
        list<object> resultFromAnother = (list<object>)result;
        
        system.assert(resultFromAnother != null && resultFromAnother.size() ==4,'Should have brough "thirdResult" json element');
        
    }
    
    @IsTest
    public static void SelectMixedElementsChildOfSelectedIndexReturns(){
        string rawJson = '{"results":[{"somex":"somey"},{"somem":{"aroute":[{"you":"think"},{"what":"do"},{"crazy":{"name":"value"}},{"is":"anja"},{"this":"yup"}],"asecond":{"athird":"route"}}},{"somer":"somes"},{"somex":"somey"}],"blablabla":{"moreproperty":"totest"} }';
        object result = JPath.get(rawJson, '/results[2]/somem/asecond');
       
        system.assert(result instanceof map<string,object>,'should be a map');
            
        map<string,object> resultFromAnother = (map<string,object>)result;//[{"if":"wecan"},{"lets":"see"},{"the":"value"}]
        
        system.assert(resultFromAnother != null && resultFromAnother.containsKey('athird') && resultFromAnother.get('athird')=='route','Should have brough "asecond" which is a child element of the second element of the "results" parent');
                
        
        result = JPath.get(rawJson, '/results[2]/somem/aroute[3]/crazy');
      
        system.assert(result instanceof map<string,object>,'should be a map');
            
        resultFromAnother = (map<string,object>)result;
        
        system.assert(resultFromAnother != null && resultFromAnother.containsKey('name') && resultFromAnother.get('name')=='value','Should have brough third element of the "results" parent');
        
        
        result = JPath.get(rawJson, '/results[2]/somem/aroute');
      
        system.assert(result instanceof list<object>,'should be a list');
            
        List<object> listResult = (list<object>)result;
        
        system.assert(listResult != null && listResult.size() == 5 ,'Should have brough 5 elements');
        
    }
    
    @IsTest
    public static void SelectFirstSecondAndThirdElementShouldReturnIt(){
        string rawJson = '{"results":[{"somex":"somey"},{"somem":"somed"},{"somer":"somes"},{"somex":"somey"}],"blablabla":{"moreproperty":"totest"} }';
        
        
        object result = JPath.get(rawJson, '/results[2]');
      
        system.assert(result instanceof map<string,object>,'should be a map');
            
        map<string,object> resultFromAnother = (map<string,object>)result;
        
        system.assert(resultFromAnother != null && resultFromAnother.containsKey('somem') && resultFromAnother.get('somem')=='somed','Should have brough second element of the "results" parent');
                
        
        result = JPath.get(rawJson, '/results[3]');
      
        system.assert(result instanceof map<string,object>,'should be a map');
            
        resultFromAnother = (map<string,object>)result;
        
        system.assert(resultFromAnother != null && resultFromAnother.containsKey('somer') && resultFromAnother.get('somer')=='somes','Should have brough third element of the "results" parent');
        
        
        result = JPath.get(rawJson, '/results[1]');
      
        system.assert(result instanceof map<string,object>,'should be a map');
            
        resultFromAnother = (map<string,object>)result;
        
        system.assert(resultFromAnother != null && resultFromAnother.containsKey('somex') && resultFromAnother.get('somex')=='somey','Should have brough first element of the "results" parent');
        
    }
    
    @IsTest
    public static void SelectSingleElement(){
        string rawJson = '{"info":{"statuscode":0,"copyright":{"text":"\u00A9 2016 MapQuest, Inc.","imageUrl":"http://api.mqcdn.com/res/mqlogo.gif","imageAltText":"\u00A9 2016 MapQuest, Inc."},"messages":[]},"options":{"maxResults":-1,"thumbMaps":true,"ignoreLatLngInput":false},"results":[{"providedLocation":{"location":"Santo Domingo, Republica Dominicana"},"locations":[{"street":"","adminArea6":"","adminArea6Type":"Neighborhood","adminArea5":"Santo Domingo","adminArea5Type":"City","adminArea4":"","adminArea4Type":"County","adminArea3":"DISTRITO NACIONAL","adminArea3Type":"State","adminArea1":"DO","adminArea1Type":"Country","postalCode":"","geocodeQualityCode":"A5XAX","geocodeQuality":"CITY","dragPoint":false,"sideOfStreet":"N","linkId":"282817645","unknownInput":"","type":"s","latLng":{"lat":18.463916,"lng":-69.894664},"displayLatLng":{"lat":18.463916,"lng":-69.894664},"mapUrl":"http://www.mapquestapi.com/staticmap/v4/getmap?key=xxxxx&type=map&size=225,160&pois=purple-1,18.463916,-69.894664,0,0,|&center=18.463916,-69.894664&zoom=12&rand=51595886"}]}]}';
        
        object result = JPath.get(rawJson,'/results[1]/locations[1]/latLng');
        
        system.assert(result instanceof map<string,object>,' shoud be a map ' + result);
        
        map<string,object> finalResult = (map<string,object>) result;
        system.assert(finalResult.containsKey('lat'),'should contain lat ' + finalResult);
        system.assert(finalResult.containsKey('lng'),'should contain lng '+ finalResult);
        system.assert(finalResult.get('lat') == 18.463916,finalResult.get('lat'));
        system.assert(finalResult.get('lng') == -69.894664,finalResult.get('lng'));
        
    } 
   
    @IsTest
    public static void SelectSingleElementChildOfTheRootDoesNotReturnsIt(){
         object result = JPath.get('{"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}}', '/results/another');
       
        system.assert(result == null,'Should not return');
      
    }
    
  
    @IsTest
    public static void SelectSingleElementChildOfTheRootDoesNotReturnsTooIt(){
         object result = JPath.get('{"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}}', '/results[0]');
   
        system.assert(result == null,'Should not return');
      
    } 
}
