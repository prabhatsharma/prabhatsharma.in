#!/bin/sh
# invalidate cloudfront cache so that latest files can be served
aws cloudfront create-invalidation --distribution-id E2MZ46EDHY6R32 --paths=/ --profile=personal