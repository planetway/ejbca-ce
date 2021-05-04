#!/usr/bin/env python3

import boto3
import logging
import sys
import os
from botocore.exceptions import ClientError, NoCredentialsError
from cryptography import x509


def file_name_from_crl(crl):
    """Load CRL and return file name from extensions
    :param crl: CRL to parse
    """
    try:
        with open(crl, 'rb') as f:
            crl_data = f.read()
        crl_object = x509.load_der_x509_crl(crl_data)
        file_name = crl_object.extensions.get_extension_for_class(
            x509.IssuingDistributionPoint
                ).value.full_name[0].value.split('/')[3]
    except (FileNotFoundError, ValueError) as e:
        logging.error(e)
        return False
    return file_name


def upload_file(file_name, bucket, object_name=None):
    """Upload a file to an S3 bucket

    :param file_name: File to upload
    :param bucket: Bucket to upload to
    :param object_name: S3 object name. If not specified then file_name is used
    :return: True if file was uploaded, else False
    """

    # If S3 object_name was not specified, use file_name
    if object_name is None:
        object_name = file_name

    # Upload the file
    try:
        s3_client = boto3.client('s3')
        response = s3_client.upload_file(file_name, bucket, object_name)
    except (ClientError, NoCredentialsError) as e:
        logging.error(e)
        return False
    return response


def variable_from_environment(var):
    try:
        return os.environ[var]
    except (KeyError) as e:
        logging.error(e)
        return False


def main():
    try:
        input_file = sys.argv[1]
        bucket_name = variable_from_environment('AWS_S3_BUCKET')
        file_name = file_name_from_crl(input_file)
        upload_file(input_file, bucket_name, file_name)
    except (FileNotFoundError, IndexError, TypeError) as e:
        logging.error(e)
        return sys.exit(1)


# Run main function
if __name__ == '__main__':
    main()
