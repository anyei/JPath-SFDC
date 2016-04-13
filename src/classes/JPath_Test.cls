/*
 * Author : Angel Robles
 * Apex Class Tested: JPath
 * Purpose: Unit testing for JPath apex class. Should contain all the supported scenarios.
 * 
 * */
@IsTest
public class JPath_Test {

    @IsTest
    public static void SelectSingleElementFromTheRootReturnsIt(){
        object result = JPath.get('{"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}}', '/results');
        system.assert(result != null,'Should bring something');
    }
    
    @IsTest
    public static void SelectSingleElementSecondInTheRootReturnsIt(){
        object result = JPath.get('{"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}}', '/another');
       
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
        
        system.assert(result instanceof map<string,object>,' shoud be a map ');
        
        map<string,object> finalResult = (map<string,object>) result;
        system.assert(finalResult.containsKey('lat'),'should contain lat');
        system.assert(finalResult.containsKey('lng'),'should contain lng');
        system.assert(finalResult.get('lat') == 18.463916,finalResult.get('lat'));
        system.assert(finalResult.get('lng') == -69.894664,finalResult.get('lng'));
        
    }
    
    @IsTest
    public static void SelectSingleElementChildOfTheRootDoesNotReturnsIt(){
         object result = JPath.get('{"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}}', '/results/another');
       
        system.assert(result == null,'Should not return');
      
    }
}