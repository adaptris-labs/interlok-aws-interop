# interlok-aws-interop

Interlok configuration that has one workflow:

* Exposes a HTTP endpoint `/api/kinesis` which will produce to kinesis stream `myStream`

Inspired by this blog post: [Testing Interlok interoperability with AWS](https://interlok.adaptris.net/blog/2019/08/30/interlok-interop-with-aws.html)

## Setup

```shell
# start localstack
docker-compose up -d
# build interlok
gradle clean install
# start interlok
cd ./build/distribution
java -jar ./lib/interlok-boot.jar
```

## Testing

### Kinesis

```shell
# Follow kinesis stream iterator logs
docker-compose logs -f localstackhttps
curl -X POST http://localhost:8080/api/kinesis -d '{ "key" : "value" }'
```

## TOOD

* Add S3 tests
* Add SQS tests
* Add SNS tests
