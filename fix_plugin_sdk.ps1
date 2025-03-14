# Locate the plugin directory
$pubCachePath = "$env:LOCALAPPDATA\Pub\Cache\hosted\pub.dev"
$pluginDir = Get-ChildItem -Path $pubCachePath -Filter "flutter_plugin_android_lifecycle-*" -Directory | 
                Select-Object -First 1 -ExpandProperty FullName

if ($null -ne $pluginDir) {
    Write-Host "Found plugin at: $pluginDir"
    
    # Locate the build.gradle file
    $buildGradlePath = Join-Path -Path $pluginDir -ChildPath "android\build.gradle"
    
    if (Test-Path $buildGradlePath) {
        Write-Host "Found build.gradle at: $buildGradlePath"
        
        # Read the file content
        $content = Get-Content -Path $buildGradlePath -Raw
        
        # Replace compileSdk 35 with compileSdk 34
        $newContent = $content -replace "compileSdk\s+35", "compileSdk 34"
        
        # Write the modified content back
        Set-Content -Path $buildGradlePath -Value $newContent
        
        Write-Host "Successfully updated plugin to use compileSdk 34"
    } else {
        Write-Host "Could not find build.gradle file"
    }
} else {
    Write-Host "Could not find flutter_plugin_android_lifecycle plugin directory"
}
