param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("dev", "stage", "prod")]
    [string]$Environment,
    
    [Parameter(Mandatory=$false)]
    [ValidateSet("plan", "apply", "destroy")]
    [string]$Action = "apply",
    
    [Parameter(Mandatory=$false)]
    [switch]$AutoApprove,
    
    [Parameter(Mandatory=$false)]
    [string]$VarFile = "terraform.tfvars",
    
    [Parameter(Mandatory=$false)]
    [string]$Var = @()
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Set environment directory
$envDir = "../environments/$Environment"

# Validate environment directory
if (-not (Test-Path $envDir)) {
    Write-Error "Environment directory not found: $envDir"
    exit 1
}

# Change to environment directory
Push-Location $envDir

try {
    # Initialize Terraform if .terraform directory doesn't exist
    if (-not (Test-Path ".terraform")) {
        Write-Host "Initializing Terraform..." -ForegroundColor Cyan
        terraform init -input=false
        if ($LASTEXITCODE -ne 0) {
            throw "Terraform initialization failed"
        }
    }
    
    # Format Terraform code
    Write-Host "Formatting Terraform code..." -ForegroundColor Cyan
    terraform fmt -recursive
    
    # Validate Terraform configuration
    Write-Host "Validating Terraform configuration..." -ForegroundColor Cyan
    terraform validate
    if ($LASTEXITCODE -ne 0) {
        throw "Terraform validation failed"
    }
    
    # Build variable arguments
    $varArgs = @()
    if (Test-Path $VarFile) {
        $varArgs += "-var-file=$VarFile"
    }
    
    # Add additional variables if provided
    foreach ($varItem in $Var) {
        $varArgs += "-var"
        $varArgs += $varItem
    }
    
    # Execute Terraform command based on action
    switch ($Action) {
        "plan" {
            Write-Host "Creating execution plan..." -ForegroundColor Cyan
            terraform plan -out=tfplan -input=false @varArgs
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform plan failed"
            }
        }
        "apply" {
            # Always run plan first
            Write-Host "Creating and applying execution plan..." -ForegroundColor Cyan
            $planFile = "tfplan"
            
            terraform plan -out=$planFile -input=false @varArgs
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform plan failed"
            }
            
            # Apply the plan
            $approveArg = if ($AutoApprove) { "-auto-approve" } else { "" }
            terraform apply $approveArg -input=false $planFile
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform apply failed"
            }
            
            # Clean up plan file
            if (Test-Path $planFile) {
                Remove-Item $planFile -Force
            }
        }
        "destroy" {
            Write-Host "Destroying infrastructure..." -ForegroundColor Cyan
            $approveArg = if ($AutoApprove) { "-auto-approve" } else { "" }
            terraform destroy $approveArg -input=false @varArgs
            if ($LASTEXITCODE -ne 0) {
                throw "Terraform destroy failed"
            }
        }
    }
    
    Write-Host "Operation completed successfully!" -ForegroundColor Green
} catch {
    Write-Error "Error during deployment: $_"
    exit 1
} finally {
    # Return to original directory
    Pop-Location
}

# Usage examples:
# .\deploy.ps1 -Environment dev -Action plan
# .\deploy.ps1 -Environment dev -Action apply -AutoApprove
# .\deploy.ps1 -Environment dev -Action destroy -AutoApprove
