# JPath-SFDC
Query json data made simple in salesforce using apex.

I know there are many solutions out there in many programming languages to query or select json data using an xpath type of queries with some variations (you can search on github or even on google and you'll get some), but, i could not find something for me to use in apex for salesforce.com.

JPath is an attempt to create an useful tool for this purpose, the query pattern should be simple and as apex has many limitations will try to keep that in mind when processing and querying the json data. For now we are just traversing thru the properties.

### Install

##### Deploy to Salesforce Button

<a href="https://githubsfdeploy.herokuapp.com?owner=anyei&repo=JPath-SFDC">
  <img alt="Deploy to Salesforce"
       src="https://raw.githubusercontent.com/afawcett/githubsfdeploy/master/src/main/webapp/resources/img/deploy.png">
</a>

##### Manual Install

You may manually create the class within your org and copy paste the content of JPath class as for the JPath_Test. 

### Usage
_____
Querying Json where Root element is an Array

```sh
string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
         object result = JPath.get(rawJson, '/results');
      
         system.assert(result instanceof List<object>,'should be a list');
      
         List<object> results = (List<object>)result;
          
         system.assert(results != null && results.size() == 2 ,'Should bring 2 results '+ results.size());
          

```
The variable "result" will contain a list of any value or object in a property located at the top level of the json array, in this case "results", but the type of the variable "listOfResults" is an object as that's what you get from the "get" method, it should be casted to either a List<object> or Map<string,object> (for now maybe), depending on the actual json content.

```sh
  string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple","Red Apple","yellow apple"]}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
          JPath jpathExec = new JPath(rawJson);
          
          object result = jpathExec.get('/results/aField');
      
          system.assert(result instanceof List<object>,'should be a list ' + result);
      
          List<object> results = (List<object>)result;
          
          system.assert(results != null && results.size() == 2 && results[1] == 'aValued' ,'Should bring 2 result ' + results + ' '+ results.size());

```
In this example, the values "Avalue" and "Avalued" are selected, both values were in a property called "aField'.

```sh
 JPath jpathExec = new JPath(rawJson);
          
 object result = jpathExec.get('/results/aField');
  ```
  Another variation is to create an instance of JPath and just call get, pretty much doing the same thing as if you call the static get method.
____
Querying Json where Root is an Object

```sh
 string rawJson = ' {"results":[{"aField":"Avalue"},{"aField":"Avalued"},{"listOfFruits":["apple","green apple",[1,2,5,4],"yellow apple"]}] }';
          
          JPath jpathExec = new JPath(rawJson);
          
          object result = jpathExec.get('/results');
      
          system.assert(result instanceof List<object>,'should be a list ' + result);
          
          List<object> results = (List<Object>)result;
          
          system.assert(results != null && results.size() == 3,'Should bring 3 result ' + results);
          

```
So the root element of the json data can also be an object not an array, the query will perform the same and the selection will be the same. In this example the root object containing a property called "results" which value is an array with three items.

  
#### JPath Class  
##### Instance Methods
###### get
Returns an object type which is the resulting value from the selection.

###### arguments
**path**
Type of string, the well formed path or selector to get the json from the rawJson.


###### Example
```sh
 JPath jpathExec = new JPath(rawJson);
          
 object result = jpathExec.get('/results/aField');
  ```
##### Static Methods

###### get
Returns an object type which is the resulting value from the selection.

###### arguments
**rawJson**
Type of string, Raw json data.
**path**
Type of string, the well formed path or selector to get the json from the rawJson.

###### Example
```sh
 string rawJson = '[ {"results":[{"aField":"Avalue"},{"aField":"Avalue"}],"another":{"somef":"somed"}},{"second":"object"},{"second":"objecty"},{"second":"objectz"},{"second":"objectm"},{"third":"objectx"} ]';
        
         object result = JPath.get(rawJson, '/results');
  ```

#### JPath Supported Selectors
| JPath Selectors Types | Usage | Description |
|:---------------------:|:------------------------------------------------------------------------------------------------:|:------------------------------------------------------------------------------------------------------------------------:|
| property | ```/propertyName or /propertyName/AnotherProperty``` | Gets any value from the propertyName in any json record of the current path |
| index predicate | - <code>/[1]</code>
 - <code>/propertyName[1]</code> 
 - <code>/propertyName[3]/[4]</code> 
 - <code>/propertyName/[4]/someMore/[1]</code>  and so on.. | It is not zero based index, 1 means first record. Gets only a single element from the specific path of the json record.  |
| conditional predicate | <code>/[aField="aValue"] or /property[aField="aValue" &#124;&#124;  aField="aValue2"] or /property[aField="Avalue"]/property2 or /property[aField="aValue" && Afield2="AValue"]/[aField="aValue"]</code> | Simple filters to norrow down the elements selected, operators supported are : <code>&&, &#124;&#124;, <, >, <=, >=, =, != </code>|
|  |  |  |

### Issues
Please refer to the <a href="https://github.com/anyei/JPath-SFDC/issues">Issues</a> section.

### Pending
1. Code is ugly and not optimal and undocumented, need to improve it so that its better and faster.2. 
2. To do a good documentation, update the readme file to provide more explanation and create a wiki page.
3. Not completed yet.


