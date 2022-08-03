#!/usr/bin/env bash

pipeline_execution_id=$(aws codepipeline list-pipeline-executions \
    --pipeline-name paas-csls-splunk-broker \
    --max-items 1 | jq -r '.pipelineExecutionSummaries[0].pipelineExecutionId')

techops_artifact=$(aws codepipeline list-action-executions \
    --pipeline-name paas-csls-splunk-broker \
    --filter pipelineExecutionId="${pipeline_execution_id}" \
    | jq '.actionExecutionDetails[] | select(.actionName=="TechOpsRepo") | .output.outputArtifacts[0].s3location')
# techops_artifact is a JSON object in the form
# {
#  "bucket": "BUCKET_NAME",
#  "key": "path/to/techops/repo"
# }

bucket=$(jq -r '.bucket' <<< "${techops_artifact}")
key=$(jq -r '.key' <<< "${techops_artifact}")

echo "Starting build"
aws codebuild start-build \
    --project-name codepipeline-paas-csls-splunk-broker-staging-test \
    --artifacts-override type=CODEPIPELINE \
    --source-type-override S3 \
    --source-location-override \
    ${bucket}/${key}
