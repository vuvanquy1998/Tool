#!/bin/bash
# minhphong306.wordpress.com
# ~/.smartgit.sh
 
server="gitlab.shopbase.dev"
SHOULD_PROCESS=$(git remote -v | grep "origin.*(push)" | grep -c "$server")
  
flag=$1
if [ $SHOULD_PROCESS -ne 0 ]; then
  CHECK=$(git remote -v | grep "origin.*(push)")
  REPO_NAME=$(git remote -v | grep "origin.*(push)" | sed 's/.*:\(.*\)\.git.*/\1/g')
  BRANCH_NAME=$(git rev-parse --abbrev-ref HEAD)
  echo "git push $flag origin $BRANCH_NAME\n"
  $(git push $flag origin $BRANCH_NAME)
  echo ""
  echo "\n>> Merge dev:"
  echo "    https://$server/$REPO_NAME/-/merge_requests/new?merge_request%5Bsource_branch%5D=$BRANCH_NAME&merge_request%5Btarget_branch%5D=dev"
  echo "\n>> Merge master:"
  echo "    https://$server/$REPO_NAME/-/merge_requests/new?merge_request%5Bsource_branch%5D=$BRANCH_NAME&merge_request%5Btarget_branch%5D=master"
  echo "\n>> Merge stag:"
  echo "    https://$server/$REPO_NAME/-/merge_requests/new?merge_request%5Bsource_branch%5D=$BRANCH_NAME&merge_request%5Btarget_branch%5D=staging"
  echo "\n>> Merge prod:"
  echo "    https://$server/$REPO_NAME/-/merge_requests/new?merge_request%5Bsource_branch%5D=$BRANCH_NAME&merge_request%5Btarget_branch%5D=production"
  echo ""
else
  echo "Not git repo or not has origin remote. Please check again."
fi
