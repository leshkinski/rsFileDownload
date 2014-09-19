
rsFileDownload
=======================

<pre>
rsFileDownload newrelic_net_msi
{
	Ensure = "Present"
	SourceURL = "http://849eb47b121a37391a80-4ab5a1bc87ee201fab7ef43d1b9238c2.r90.cf1.rackcdn.com/NewRelicAgent_x64_3.6.177.0.msi"
	DestinationFile = "C:\DevOps\Packages\NewRelicNewRelicAgent_x64_3.6.177.0.msi"
}
</pre>		
		

RELEASE v1.2.0
Eliminated separate folder and file variables
Converted from webclient to invoke-webrequest
added error logging

RELEASE v1.0.1

Added logic to create folder before download attempt.
Added try/catch logic to retry failed downloads 3 times before.
