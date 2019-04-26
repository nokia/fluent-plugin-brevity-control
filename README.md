# fluent-plugin-suppress
https://travis-ci.org/fujiwara/fluent-plugin-suppress

## Copyright

Copyright (c) 2012- FUJIWARA Shunichiro
License   Apache License, Version 2.0

fluent-plugin-brevity-control is built based on fluent-plugin-suppress by Nokia CLOG Team.

## Configuration

Parameters of fluent-plugin-brevity-control:

|Parameter Name|                      Description                                          |
|---|---|
|type|**Required**. Its value must be **brevity_control**|
|interval|(integer) checking interval for duplicated message. Default is 300s.|
|num|(integer) allowed message number in above interval. Default is 3|
|attr_key|**Required**.(string) checked keys in log record. If not preset, filter all message by tag|
|max_slot_num|(integer) upper limit of internal hash table which matching message. Default is 100000|
|stats_msg_fields|**Optional**.(string) fileds from log record, which are appended to dumped statistics message as additional fields|
|stats_msg_tag|**Optional**. (string) stream tag to which the statistics message is sent|
|all_keys_used|(bool)If its values is **true**, messages won't be filter by brevity control if not all the fields, which are configured in attr_keys, are contained in the messages. Default is true.|

## Examples

```
<filter nokia.logging.log>
 @type brevity_control
 interval 10
 num 2
 attr_keys log.message, host
 max_slot_num 100000
</filter>
```
Input and output of upper example configuration.
```
Input1: 2012-11-22 11:22:33 UTC  {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input2: 2012-11-22 11:22:34 UTC  {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input3: 2012-11-22 11:22:35 UTC  {"id":3, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input4: 2012-11-22 11:22:36 UTC  {"id":4, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input5: 2012-11-22 11:22:36 UTC  {"id":5, "host":"app01", "log":{"message":"it's a test for brevity control"}}
Input6: 2012-11-22 11:22:45 UTC  {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input7: 2012-11-22 11:22:46 UTC  {"id":7, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input8: 2012-11-22 11:22:47 UTC  {"id":8, "host":"web01", "log":{"message":"it's a test for brevity control"}}

-------------------------------------------------------------------------------------------------------------------

Output1: 2012-11-22 11:22:33 UTC  {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output2: 2012-11-22 11:22:34 UTC  {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output3: 2012-11-22 11:22:36 UTC  {"id":5, "host":"app01", "log":{"message":"it's a test for brevity control"}}
Output4: 2012-11-22 11:22:45 UTC {"log":"brevity control drop 2 message(s), nokia.logging.log, host=web01 | log.message=it's a test for brevity control"}
Output5: 2012-11-22 11:22:45 UTC  {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output6: 2012-11-22 11:22:46 UTC  {"id":7, "host":"web01", "log":{"message":"it's a test for brevity control"}}
```

The default value of **all_keys_used** is true. With upper configuration example, the input and output should be:
```
Input1: 2012-11-22 11:22:33 UTC  {"id":1, "level":"info", "log":{"message":"it's a test for brevity control"}}
Input2: 2012-11-22 11:22:34 UTC  {"id":2, "level":"info", "log":{"message":"it's a test for brevity control"}}
Input3: 2012-11-22 11:22:35 UTC  {"id":3, "level":"info", "log":{"message":"it's a test for brevity control"}}

---------------------------------------------------------------------------------------------------------------

Output1: 2012-11-22 11:22:33 UTC  {"id":1, "level":"info", "log":{"message":"it's a test for brevity control"}}
Output2: 2012-11-22 11:22:34 UTC  {"id":2, "level":"info", "log":{"message":"it's a test for brevity control"}}
Output3: 2012-11-22 11:22:35 UTC  {"id":3, "level":"info", "log":{"message":"it's a test for brevity control"}}
```
Here, **all_keys_used** is true, so brevity control will filter the messages only when all the fields of **attr_keys** are in the records.

In below configuration, **all_keys_use** is false.
```
#fluentd configuration
<filter nokia.logging.log>
 @type brevity_control
 interval 10
 num 2
 attr_keys log.message, host
 max_slot_num 100000
 all_keys_used false
</filter>
```
The input and output is as below.
```
Input1: 2012-11-22 11:22:33 UTC  {"id":1, "level":"info", "log":{"message":"it's a test for brevity control"}}
Input2: 2012-11-22 11:22:34 UTC  {"id":2, "level":"info", "log":{"message":"it's a test for brevity control"}}
Input3: 2012-11-22 11:22:35 UTC  {"id":3, "level":"info", "log":{"message":"it's a test for brevity control"}}
Input4: 2012-11-22 11:22:45 UTC  {"id":4, "level":"info", "log":{"message":"it's a test for brevity control"}}

---------------------------------------------------------------------------------------------------------------

Output1: 2012-11-22 11:22:33 UTC  {"id":1, "level":"info", "log":{"message":"it's a test for brevity control"}}
Output2: 2012-11-22 11:22:34 UTC  {"id":2, "level":"info", "log":{"message":"it's a test for brevity control"}}
Output3: 2012-11-22 11:22:45 UTC {"log":"brevity control drop 1 message(s), nokia.logging.log, log.message=it's a test for brevity control"}
Output4: 2012-11-22 11:22:45 UTC  {"id":4, "level":"info", "log":{"message":"it's a test for brevity control"}}
```

A configuration sample of **stats_msg_fields** as below. Take care for the output of brevity control.
Brevity control will output a log every interval if there are logs dropped.
This parameter only works on brevity control log message. 
Fields will added to brevity control log message if record contains the fields in **stats_msg_fields**
```
#fluentd configuration
<filter nokia.logging.log>
 @type brevity_control
 interval 10
 num 2
 attr_keys log.message, host
 max_slot_num 100000 
 all_keys_used false
 stats_msg_fields host, id
</filter>
```
The input and output is as below:
```
Input1: 2012-11-22 11:22:33 UTC  {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input2: 2012-11-22 11:22:34 UTC  {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input3: 2012-11-22 11:22:35 UTC  {"id":3, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input4: 2012-11-22 11:22:36 UTC  {"id":4, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input5: 2012-11-22 11:22:45 UTC  {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}

--------------------------------------------------------------------------------------------------------------

Output1: 2012-11-22 11:22:33 UTC  {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output2: 2012-11-22 11:22:34 UTC  {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output3: 2012-11-22 11:22:45 UTC {"id":6, "host":"web01", "log":"brevity control drop 2 message(s), nokia.logging.log, host=web01 | log.message=it's a test for brevity control"}
Output4: 2012-11-22 11:22:45 UTC  {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}
```

A configuration example of **stats_msg_tag**. This parameters only works on brevity control log message too.
It defines the tag of brevity control log message. Filter tag will be used as brevity control log messages' tag if this fields isn't configured.

A sample that **stats_msg_tag** isn't configured in fluentd configuration.
```
#fluentd configuration
<filter nokia.logging.log>
 @type brevity_control
 interval 10
 num 2
 attr_keys log.message, host
 max_slot_num 100000
</filter>
```
The input and output is as below.
```
#The format of input and output is:
#<time> <tag> <record>
Input1: 2012-11-22 11:22:33 UTC  nokia.logging.log   {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input2: 2012-11-22 11:22:34 UTC  nokia.logging.log   {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input3: 2012-11-22 11:22:35 UTC  nokia.logging.log   {"id":3, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input4: 2012-11-22 11:22:36 UTC  nokia.logging.log   {"id":4, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input5: 2012-11-22 11:22:45 UTC  nokia.logging.log   {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}

--------------------------------------------------------------------------------------------------------------

Output1: 2012-11-22 11:22:33 UTC  nokia.logging.log  {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output2: 2012-11-22 11:22:34 UTC  nokia.logging.log  {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output3: 2012-11-22 11:22:45 UTC nokia.logging.log   {"log":"brevity control drop 2 message(s), nokia.logging.log, host=web01 | log.message=it's a test for brevity control"}
Output4: 2012-11-22 11:22:45 UTC  nokia.logging.log  {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}
```

A sample that **stats_msg_tag** is configured in fluentd configuration.
```
#fluentd configuration
<filter nokia.logging.log>
 @type brevity_control
 interval 10
 num 2
 attr_keys log.message, host
 max_slot_num 100000
 stats_msg_tag brevity.control.log
</filter>
```
The input and output is as below.
```
#The format of input and output is:
#<time> <tag> <record>
Input1: 2012-11-22 11:22:33 UTC  nokia.logging.log   {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input2: 2012-11-22 11:22:34 UTC  nokia.logging.log   {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input3: 2012-11-22 11:22:35 UTC  nokia.logging.log   {"id":3, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input4: 2012-11-22 11:22:36 UTC  nokia.logging.log   {"id":4, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Input5: 2012-11-22 11:22:45 UTC  nokia.logging.log   {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}

--------------------------------------------------------------------------------------------------------------

Output1: 2012-11-22 11:22:33 UTC  nokia.logging.log  {"id":1, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output2: 2012-11-22 11:22:34 UTC  nokia.logging.log  {"id":2, "host":"web01", "log":{"message":"it's a test for brevity control"}}
Output3: 2012-11-22 11:22:45 UTC brevity.control.log   {"log":"brevity control drop 2 message(s), nokia.logging.log, host=web01 | log.message=it's a test for brevity control"}
Output4: 2012-11-22 11:22:45 UTC  nokia.logging.log  {"id":6, "host":"web01", "log":{"message":"it's a test for brevity control"}}
```

