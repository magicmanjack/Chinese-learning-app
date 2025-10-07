import { S3Client, GetObjectCommand } from "@aws-sdk/client-s3";

const client = new S3Client();
let num = 0;

export const handler = async (event) => {
  
  const bucket = "jack-bredenbecks-metrics-bucket";
  const key = "number.txt";

  try {
    const response = await client.send(new GetObjectCommand({
        Bucket: bucket,
        Key: key,
    }));
    num = await response.Body.transformToString();
  } catch (err) {
      console.log(err);
      const message = `Error getting object ${key} from bucket ${bucket}. Make sure they exist and your bucket is in the same region as this function.`;
      console.log(message);
      throw new Error(message);
  }

  const response = {
    statusCode: 200,
    'headers': {
      'Content-Type': 'text/html'
    },
    body: `<h1>Number of accounts created: ${num}</h1>`,
  };
  return response;
};