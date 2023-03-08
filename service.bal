import ballerinax/github;
import ballerina/log;
import ballerina/http;


configurable string githubAccessToken = ?;


type SummarizedIssues record {
   int number;
   string title;
};


# A service representing a network-accessible API
# bound to port `9090`.
service / on new http:Listener(9090) {


   resource function get summary/[string orgName]/repository/[string repoName]() returns SummarizedIssues[]|error? {


       log:printInfo("new request for  " + orgName + " " + repoName);
       github:Client githubEp = check new (config = {
           auth: {
               token: githubAccessToken
           }
       });
       stream<github:Issue, error?> getIssuesResponse = check githubEp->getIssues(owner = orgName, repositoryName = repoName, issueFilters = {
           states: [github:ISSUE_OPEN]
       });


       SummarizedIssues[]? summary = check from github:Issue issue in getIssuesResponse
           order by
       issue.number descending
           limit 10
           select {number: issue.number, title: issue.title.toString()};


       return summary;
   }
}
