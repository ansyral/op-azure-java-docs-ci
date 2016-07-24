$ErrorActionPreference = 'Stop'


$scriptPath = $MyInvocation.MyCommand.Path
$scriptHome = Split-Path $scriptPath

Push-Location $scriptHome

$azurejavasdk = "azure-sdk-for-java"


# get and update code2yaml.json
& git clone "git@github.com:ansyral/OP-Azure-Java-Documentation.git"
$config = Get-Content OP-Azure-Java-Documentation\code2yaml.json -Raw | ConvertFrom-Json
$config.input_path = $azurejavasdk
$config.exclude_paths = Join-Path $azurejavasdk -ChildPath "examples"
$config.output_path = "_javadocs"
$config | ConvertToJsonSafely | Out-File "code2yaml.json"

# run code2yaml to generate metadata yaml files
& Microsoft.Content.Build.Code2Yaml code2yaml.json

# update to remote repo
Remove-Item "OP-Azure-Java-Documentation\JavaDoc\api\*" -recurse
Copy-Item -Path "_javadocs" -Destination "OP-Azure-Java-Documentation\JavaDoc\api" -Force

Push-Location "OP-Azure-Java-Documentation"
& git add .
& git commit -m "CI Updates"
& git push -u origin live
Pop-Location

Pop-Location
