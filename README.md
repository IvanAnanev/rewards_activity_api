# ActivityApi

## Installation local

- Install dependencies with `mix deps.get`
- Create and migrate your database with `mix ecto.setup`
- Start endpoint with `iex -S mix`

Now you can test endpoint with `http://localhost:4001/ping`

## Usage

### activity_requirements

```bash
curl -X GET \
  http://localhost:4001/activity_requirements \
  -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1NTc4MzE3NjEsInN1YiI6NzcsInR5cGUiOiJhY2Nlc3MifQ.dXy53Ehxkrdp-F6TrK9IF2pvKbRx4QybwvhdV1W_fcU' \
  -H 'Content-Type: application/json'
```

response 200

```json
{
  "data": [
    {
      "attributes": {
        "goal": 200,
        "has_claimed": false,
        "metric": "stand"
      },
      "id": 1,
      "type": "activity_requirements"
    },
    {
      "attributes": {
        "goal": 200,
        "has_claimed": false,
        "metric": "move"
      },
      "id": 2,
      "type": "activity_requirements"
    },
    {
      "attributes": {
        "goal": 200,
        "has_claimed": false,
        "metric": "excercise"
      },
      "id": 3,
      "type": "activity_requirements"
    }
  ]
}
```

### claim_bonus_points

```bash
curl -X POST \
  http://localhost:4001/claim_bonus_points \
  -H 'Authorization: Bearer eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE1NTc5ODc0OTAsInN1YiI6NzcsInR5cGUiOiJhY2Nlc3MifQ.5BJg7w29NWM5c0TfDGkkHuYz0LeJgNTipmNHKXsENWQ' \
  -H 'Content-Type: application/json' \
  -d '{
  "metric": "move",
  "value": 200
}'
```

response 200

```json
{
  "data": "bonus for user some@email.com for goal some_metric was claimed"
}
```
