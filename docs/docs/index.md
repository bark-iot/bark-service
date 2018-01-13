# Barks Service

For full Bark documentation visit [http://localhost/docs](http://localhost/docs).

## Authorization

To perform any requests you need to send user token via `Authorization` header. Example:
`Authorization: Bearer <token>`.

## Create Bark

POST `/houses/:house_id/barks`

*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required


*POST parameters*

Name            | Validation
------------    | -------------
action_id       | required 
trigger_id      | required 
title           | required
mappings        | optional
settings        | optional

*Response [200]*

```json
{
  "id": 1,
  "house_id": 1,
  "trigger_id": 1,
  "action_id": 1,
  "title": "MyBark",
  "mappings": "{\"input\": \"output\"}",
  "settings": "{\"param\": \"value\"}",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

`mappings` - pairs of trigger's inputs mapped to action's outputs
`settings` - pairs of of key value used to provide additional config for bark

*Error Response [422]*

```json
[
  ["title", ["must be filled"]]
]
```

*Error Response [401]*

Wrong user token

## Update Bark

PUT `/houses/:house_id/barks/:id`

*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required
id           | required


*POST parameters*

Name          | Validation
------------  | -------------
action_id       | optional 
trigger_id      | optional 
title           | required
mappings        | optional
settings        | optional

*Response [200]*

```json
{
  "id": 1,
  "house_id": 1,
  "trigger_id": 1,
  "action_id": 1,
  "title": "MyBark",
  "mappings": "{\"input\": \"output\"}",
  "settings": "{\"param\": \"value\"}",
  "created_at": "2017-11-11 11:04:44 UTC",
  "updated_at": "2017-1-11 11:04:44 UTC"
}
```

*Error Response [422]*

```json
[
  ["title", ["must be filled"]]
]
```

*Error Response [401]*

Wrong user token

## List Barks

GET `/houses/:house_id/barks`

*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required

*Response [200]*

```json
[
    {
      "id": 1,
      "house_id": 1,
      "trigger_id": 1,
      "action_id": 1,
      "title": "MyBark",
      "mappings": "{\"input\": \"output\"}",
      "settings": "{\"param\": \"value\"}",
      "created_at": "2017-11-11 11:04:44 UTC",
      "updated_at": "2017-1-11 11:04:44 UTC"
    }
]
```

*Error Response [401]*

No token provided

## Delete Bark

DELETE `/houses/:house_id/barks/:id`


*PATH parameters*

Name         | Validation
------------ | ------------- 
house_id     | required
id           | required

*Response [200]*

Deleted.

*Error Response [401]*

No token provided