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
 attr_keys log.message, level
 max_slot_num 100000
 stats_msg_fields kubernetes
</filter>
```
Input and output of upper example configuration.
```
Input1:
Input2:
Input3:
Input4:
Input5:
Input6:
Output1:
Output2:
Output3:
Output4:
```
