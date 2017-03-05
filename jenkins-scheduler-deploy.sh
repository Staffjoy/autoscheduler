set -e
export name="master-${BUILD_NUMBER}"
echo "Beginning the deploy of build ${BUILD_NUMBER}"

tag="master-${BUILD_NUMBER}"

echo ""
echo "DEPLOYING $tag"
echo ""

# Deploy to prod
aws elasticbeanstalk update-environment \
    --environment-name "scheduler-prod" \
    --version-label "$tag"

# # Polling to see whether deploy is done
deploystart=$(date +%s)
timeout=1000 # Seconds to wait before error
threshhold=$((deploystart + timeout))
while true; do
    # Check for timeout
    timenow=$(date +%s)
    if [[ "$timenow" > "$threshhold" ]]; then
        echo "Timeout - $timeout seconds elapsed"
        exit 1
    fi

    # See what's deployed
    version=`aws elasticbeanstalk describe-environments --application-name "staffjoy-scheduler" --environment-name "scheduler-prod" --query "Environments[*].VersionLabel" --output text`
    status=`aws elasticbeanstalk describe-environments --application-name "staffjoy-scheduler" --environment-name "scheduler-prod" --query "Environments[*].Status" --output text`

    if [ "$version" != "$tag" ]; then
        echo "Tag not updated (currently $version). Waiting."
        sleep 10
        continue
    fi
    if [ "$status" != "Ready" ]; then
        echo "System not Ready -it's $status. Waiting."
        sleep 10
        continue
    fi
    break
done

