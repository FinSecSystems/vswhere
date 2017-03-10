# Copyright (C) Microsoft Corporation. All rights reserved.
# Licensed under the MIT license. See LICENSE.txt in the project root for license information.

Describe 'vswhere -legacy' {
    BeforeEach {
        # Make sure localized values are returned consistently across machines.
        $enu = [System.Globalization.CultureInfo]::GetCultureInfo('en-US')

        [System.Globalization.CultureInfo]::CurrentCulture = $enu
        [System.Globalization.CultureInfo]::CurrentUICulture = $enu
    }

    AfterEach {
        # Make sure the registry is cleaned up.
        Remove-Item HKLM:\Software\WOW6432Node\Microsoft\VisualStudio\SxS\VS7 -Force -ErrorAction 'SilentlyContinue'
    }

    Context 'no legacy' {
        It 'returns 2 instances' {
            $instances = C:\bin\vswhere.exe -legacy -format json | ConvertFrom-Json
            $instances.Count | Should Be 2
        }
    }

    Context 'has legacy' {
        BeforeEach {
             New-Item HKLM:\Software\WOW6432Node\Microsoft\VisualStudio\SxS\VS7 -Force | ForEach-Object {
                 foreach ($version in '10.0', '14.0') {
                     $_ | New-ItemProperty -Name $version -Value "C:\VisualStudio\$version" -Force
                 }
             }
        }

        It 'returns 4 instances' {
            $instances = C:\bin\vswhere.exe -legacy -format json | ConvertFrom-Json
            $instances.Count | Should Be 4
        }

        It '-version "10.0" returns 4 instances' {
            $instances = C:\bin\vswhere.exe -legacy -version '10.0' -format json | ConvertFrom-Json
            $instances.Count | Should Be 4
        }

        It '-version "14.0" returns 3 instances' {
            $instances = C:\bin\vswhere.exe -legacy -version '14.0' -format json | ConvertFrom-Json
            $instances.Count | Should Be 3
        }

        It '-version "[10.0,15.0)" returns 2 instances' {
            $instances = C:\bin\vswhere.exe -legacy -version '[10.0,15.0)' -format json | ConvertFrom-Json
            $instances.Count | Should Be 2
        }
    }
}