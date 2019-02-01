Import-Module (Join-Path $PSScriptRoot "..\PoshSSDTBuildDeploy") -Force


InModuleScope "PoshSSDTBuildDeploy" {

describe "Get-SqlCmdVars" {
    context "Tests for sql command variables" {

        it "Should fail when there are missing variables and FailOnMissingVariables is set " {
            #Arrange
            $testVar1 = 'testVar1'
            $testVar2 = 'testVar2'

            #Act
            $SQLCmdVars = @{'testVar1' = 'dummy1'
                            'testVar2' = 'dummy2'
                            'testVar3' = 'dummy2'}
            #Assert
            {Get-SqlCmdVars -sqlCommandVariableValues $SQLCmdVars -FailOnMissingVariables} | Should -Throw "The following SqlCmd variables are not defined in the current session (but are defined in the publish profile): testVar3"

        }

        it "Should NOT fail when there are missing variables and FailOnMissingVariables is NOT set " {
            #Arrange
            $testVar1 = 'testVar1'
            $testVar2 = 'testVar2'

            #Act
            $SQLCmdVars = @{'testVar1' = 'dummy1'
                            'testVar2' = 'dummy2'
                            'testVar3' = 'dummy2'}
            #Assert
            {Get-SqlCmdVars -sqlCommandVariableValues $SQLCmdVars } | Should -not -Throw

        }

        it "Should NOT fail when there are NO missing variables  " {
            #Arrange
            $testVar1 = 'testVar1'
            $testVar2 = 'testVar2'
            $testVar3 = 'testVar2'

            #Act
            $SQLCmdVars = @{'testVar1' = 'dummy1'
                            'testVar2' = 'dummy2'
                            'testVar3' = 'dummy2'}
            #Assert
            {Get-SqlCmdVars -sqlCommandVariableValues $SQLCmdVars } | Should -not -Throw

        }
        
    }

}


}


