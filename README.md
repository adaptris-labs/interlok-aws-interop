# interlok-aws-interop [![Actions Status](https://github.com/adaptris-labs/interlok-aws-interop/workflows/verifyInterlokConfig/badge.svg)](https://github.com/adaptris-labs/interlok-aws-interop/actions)

Interlok configuration that has three workflow:

* Workflow that exposes HTTP endpoint `/api/kinesis` which will produce to kinesis stream `myStream`
* Workflow that exposes `/api/s3/..` REST style operations
* Workflow that exposes `/api/s3utils/...` for everything not covered in s3 REST workflow

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

### S3

```shell
# Upload File
curl -X POST -H "Content-Type: application/json" -d '{"key": "value"}' "http://localhost:8085/api/s3/file.txt"
# List Files
curl "http://localhost:8085/api/s3/"
# Get File
curl "http://localhost:8085/api/s3/file.txt"
# Get File (use download)
curl "http://localhost:8085/api/s3/file.txt?useDownload=true"
# Delete File
curl -X DELETE "http://localhost:8085/api/s3/file.txt"
# Copy File
curl "http://localhost:8085/api/s3utils/copy?from=file.txt&to=other.txt"
# Extended Copy File (adds Content-Disposition)
curl "http://localhost:8085/api/s3utils/copy-extended?from=file.txt&to=other.txt"
# Tag a file
curl "http://localhost:8085/api/s3utils/tag?key=file.txt&tags_hello=world"
# Get Tags
curl "http://localhost:8085/api/s3utils/tag-get?key=file.txt"
# Check File Exists
curl "http://localhost:8085/api/s3utils/check-file-exists?key=nothere.txt"
```

## TODO

* Add SQS tests
* Add SNS tests
