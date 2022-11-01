# Get-Pihole
# PRTG Powershell plugin to pull basic counts from pihole. No login needed. 
#
# Scratch that, this is now an INFLUXDB INGESTION SCRIPT. 
# It's ugly. and I'm sorry. 
#
# Written by: Will McVicker
# Email will.mcvicker@furytech.net
# 
# Instructions
#
# Update URLS with your pihole URLS, [comma separated] 
# Update InfluxDB with your bucket details
# Update InfluxToken with your DB token
#
# Changelog:
#
# 2022-07-18 1.0.0
# Initial Release

# Commandline Parameters for IP

$piurls = @('192.168.1.100', '192.168.1.101')
[string]$influxdb = ""
[string]$influxtoken = ""

function dothe-pihole
{
# do pihole
foreach($piurl in $piurls)
{
$influxdeets = ""
# Verification that the IP is up
if(Test-Connection -BufferSize 32 -Count 1 -ComputerName $piurl -Quiet)
{
$site = Invoke-WebRequest "$piurl/admin/api.php?summaryRaw" -usebasicparsing
$site = $site | convertfrom-json

$totalqueries = $site.dns_queries_today
$queriesblocked = $site.ads_blocked_today
$percentblocked = ([math]::round(($queriesblocked / $totalqueries),3)) * 100
$domainsblocked = $site.domains_being_blocked


# Builds the Influx DB Script

$influxdeets += "pihole,host=$piurl QueriesToday=$totalqueries,queriesblocked=$queriesblocked,percentblocked=$percentblocked,domainsblocked=$domainsblocked"
c:\_scripts\curl.exe -i -XPOST "$influxdb" --header "Authorization: Token $influxtoken" --data-raw $influxdeets --silent


}
else
{
write-host "fail $piurl"
}
}
start-sleep -Seconds 30
}
do
{
dothe-pihole;

}until($infinity)
