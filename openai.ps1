# Use ChatGPT with PowerShell using REST-API
# https://adilshehzad786.medium.com/use-chatgpt-with-powershell-using-rest-api-fe84f0e7e27c

Install-Module -Name Microsoft.PowerShell.SecretManagement -Repository PSGallery
Install-Module -Name Microsoft.PowerShell.SecretStore -Repository PSGalleryp
Register-SecretVault -Name ChatGptAPI -ModuleName Microsoft.PowerShell.SecretStore -DefaultVault
Set-Secret-Name ChatGptAPI -Secret "shhh its a secret"
function Get-AIAnswer 
    {
        [CmdLetBinding()]
        param (
        [String]$apiKey = (Get-Secret -Name ChatGptAPI | ConvertFrom-SecureString -AsPlainText),
         
        [ValidateSet("text-davinci-003", "code-cushman-001", "code-davinci-001")]
        [String]$model = "text-davinci-003",
        
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true
            )]
        [String]$question,

        [int]$maxtokens = 4000,

        [ValidateRange(0,1)]
        [int]$temperature = 0.5
        )

    begin {
        $apiEndpoint = "https://api.openai.com/v1/completions"
    }
    
    process {
        # Set the request headers
        $headers = @{
        "Content-Type" = "application/json"
        "Authorization" = "Bearer $apiKey"
        }   

        # Set the request body
        $requestBody = @{
            "prompt" = $question
            "model" = $model
            "max_tokens" = $maxtokens
            "temperature" = $temperature
        }

        # Send the request
        $response = Invoke-RestMethod -Method POST -Uri $apiEndpoint -Headers $headers -Body (ConvertTo-Json $requestBody)

        # Print the response
        $response.choices.text

    }

    end {

    }
}
