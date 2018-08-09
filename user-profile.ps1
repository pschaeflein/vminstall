# Use this file to run your own startup commands

#######################################
#         Prompt Customization
#######################################
<#
.SYNTAX
    <PrePrompt><CMDER DEFAULT>
    λ <PostPrompt> <repl input>
.EXAMPLE
    <PrePrompt>N:\Documents\src\cmder [master]
    λ <PostPrompt> |
#>

[ScriptBlock]$PrePrompt = {
}

function Import-GitModule($Loaded) {
  if ($Loaded) { return }
  Import-Module 'C:\tools\poshgit\dahlbyk-posh-git-a4faccd\src\posh-git.psd1' > $null
  # Make sure we only run once by alawys returning true
  return $true
}



$isGitLoaded = $false
#Anonymice Powerline
$arrowSymbol = [char]0xE0B0;
$branchSymbol = [char]0xE0A0;

$defaultForeColor = "White"
$defaultBackColor = "Black"
$pathForeColor = "White"
$pathBackColor = "DarkBlue"
$gitCleanForeColor = "White"
$gitCleanBackColor = "Green"
$gitDirtyForeColor = "Black"
$gitDirtyBackColor = "Yellow"

function Write-GitPrompt() {
  $status = Get-GitStatus

  if ($status) {

    # assume git folder is clean
    $gitBackColor = $gitCleanBackColor
    $gitForeColor = $gitCleanForeColor
    if ($status.HasWorking -Or $status.HasIndex) {
      # but if it's dirty, change the back color
      $gitBackColor = $gitDirtyBackColor
      $gitForeColor = $gitDirtyForeColor
    }

    # Close path prompt
    Write-Host $arrowSymbol -NoNewLine -BackgroundColor $gitBackColor -ForegroundColor $pathBackColor

    # Write branch symbol and name
    Write-Host " " $branchSymbol " " $status.Branch " " -NoNewLine -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor

    <# Git status info
        HasWorking   : False
        Branch       : master
        AheadBy      : 0
        Working      : {}
        Upstream     : origin/master
        StashCount   : 0
        Index        : {}
        HasIndex     : False
        BehindBy     : 0
        HasUntracked : False
        GitDir       : D:\amr\SourceCode\DevDiary\.git
        #>

    # Copied from Posh-Git
    $s = $global:GitPromptSettings

    $branchStatusText = $null
    $branchStatusBackgroundColor = $s.BranchBackgroundColor
    $branchStatusForegroundColor = $s.BranchForegroundColor

    if (!$status.Upstream) {
      $branchStatusText = $s.BranchUntrackedSymbol
    }
    elseif ($status.UpstreamGone -eq $true) {
      # Upstream branch is gone
      $branchStatusText = $s.BranchGoneStatusSymbol
      $branchStatusBackgroundColor = $s.BranchGoneStatusBackgroundColor
      $branchStatusForegroundColor = $s.BranchGoneStatusForegroundColor
    }
    elseif ($status.BehindBy -eq 0 -and $status.AheadBy -eq 0) {
      # We are aligned with remote
      $branchStatusText = $s.BranchIdenticalStatusToSymbol
      $branchStatusBackgroundColor = $s.BranchIdenticalStatusToBackgroundColor
      $branchStatusForegroundColor = $s.BranchIdenticalStatusToForegroundColor
    }
    elseif ($status.BehindBy -ge 1 -and $status.AheadBy -ge 1) {
      # We are both behind and ahead of remote
      if ($s.BranchBehindAndAheadDisplay -eq "Full") {
        $branchStatusText = ("{0}{1} {2}{3}" -f $s.BranchBehindStatusSymbol, $status.BehindBy, $s.BranchAheadStatusSymbol, $status.AheadBy)
      }
      elseif ($s.BranchBehindAndAheadDisplay -eq "Compact") {
        $branchStatusText = ("{0}{1}{2}" -f $status.BehindBy, $s.BranchBehindAndAheadStatusSymbol, $status.AheadBy)
      }
      else {
        $branchStatusText = $s.BranchBehindAndAheadStatusSymbol
      }
      $branchStatusBackgroundColor = $s.BranchBehindAndAheadStatusBackgroundColor
      $branchStatusForegroundColor = $s.BranchBehindAndAheadStatusForegroundColor
    }
    elseif ($status.BehindBy -ge 1) {
      # We are behind remote
      if ($s.BranchBehindAndAheadDisplay -eq "Full" -Or $s.BranchBehindAndAheadDisplay -eq "Compact") {
        $branchStatusText = ("{0}{1}" -f $s.BranchBehindStatusSymbol, $status.BehindBy)
      }
      else {
        $branchStatusText = $s.BranchBehindStatusSymbol
      }
      $branchStatusBackgroundColor = $s.BranchBehindStatusBackgroundColor
      $branchStatusForegroundColor = $s.BranchBehindStatusForegroundColor
    }
    elseif ($status.AheadBy -ge 1) {
      # We are ahead of remote
      if ($s.BranchBehindAndAheadDisplay -eq "Full" -Or $s.BranchBehindAndAheadDisplay -eq "Compact") {
        $branchStatusText = ("{0}{1}" -f $s.BranchAheadStatusSymbol, $status.AheadBy)
      }
      else {
        $branchStatusText = $s.BranchAheadStatusSymbol
      }
      $branchStatusBackgroundColor = $s.BranchAheadStatusBackgroundColor
      $branchStatusForegroundColor = $s.BranchAheadStatusForegroundColor
    }
    else {
      # This condition should not be possible but defaulting the variables to be safe
      $branchStatusText = "?"
    }
    # if ($branchStatusText) {
      Write-Host  (" {0}" -f $branchStatusText) -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $gitForeColor
    # }

    if ($s.EnableFileStatus -and $status.HasIndex) {
      Write-Host $s.BeforeIndexText -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.BeforeIndexForegroundColor

      if ($s.ShowStatusWhenZero -or $status.Index.Added) {
        Write-Host (" $($s.FileAddedText)$($status.Index.Added.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.IndexForegroundColor
      }
      if ($s.ShowStatusWhenZero -or $status.Index.Modified) {
        Write-Host (" $($s.FileModifiedText)$($status.Index.Modified.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.IndexForegroundColor
      }
      if ($s.ShowStatusWhenZero -or $status.Index.Deleted) {
        Write-Host (" $($s.FileRemovedText)$($status.Index.Deleted.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.IndexForegroundColor
      }

      if ($status.Index.Unmerged) {
        Write-Host (" $($s.FileConflictedText)$($status.Index.Unmerged.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.IndexForegroundColor
      }

      if ($status.HasWorking) {
        Write-Host $s.DelimText -NoNewline -BackgroundColor $s.DelimBackgroundColor -ForegroundColor $s.DelimForegroundColor
      }
    }

    if ($s.EnableFileStatus -and $status.HasWorking) {
      if ($s.ShowStatusWhenZero -or $status.Working.Added) {
        Write-Host (" $($s.FileAddedText)$($status.Working.Added.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.WorkingForegroundColor
      }
      if ($s.ShowStatusWhenZero -or $status.Working.Modified) {
        Write-Host (" $($s.FileModifiedText)$($status.Working.Modified.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.WorkingForegroundColor
      }
      if ($s.ShowStatusWhenZero -or $status.Working.Deleted) {
        Write-Host (" $($s.FileRemovedText)$($status.Working.Deleted.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.WorkingForegroundColor
      }

      if ($status.Working.Unmerged) {
        Write-Host (" $($s.FileConflictedText)$($status.Working.Unmerged.Count)") -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $s.WorkingForegroundColor
      }
    }

    if ($status.HasWorking) {
      # We have un-staged files in the working tree
      $localStatusSymbol = $s.LocalWorkingStatusSymbol
      $localStatusBackgroundColor = $s.LocalWorkingStatusBackgroundColor
      $localStatusForegroundColor = $s.LocalWorkingStatusForegroundColor
    }
    elseif ($status.HasIndex) {
      # We have staged but uncommited files
      $localStatusSymbol = $s.LocalStagedStatusSymbol
      $localStatusBackgroundColor = $s.LocalStagedStatusBackgroundColor
      $localStatusForegroundColor = $s.LocalStagedStatusForegroundColor
    }
    else {
      # No uncommited changes
      $localStatusSymbol = $s.LocalDefaultStatusSymbol
      $localStatusBackgroundColor = $s.LocalDefaultStatusBackgroundColor
      $localStatusForegroundColor = $s.LocalDefaultStatusForegroundColor
    }

    if ($localStatusSymbol) {
      Write-Host (" {0}" -f $localStatusSymbol) -NoNewline -BackgroundColor $gitBackColor -ForegroundColor $localStatusForegroundColor
    }

    if ($s.EnableStashStatus -and ($status.StashCount -gt 0)) {
      Write-Host $s.BeforeStashText -NoNewline -BackgroundColor $s.BeforeStashBackgroundColor -ForegroundColor $s.BeforeStashForegroundColor
      Write-Host $status.StashCount -NoNewline -BackgroundColor $s.StashBackgroundColor -ForegroundColor $s.StashForegroundColor
      Write-Host $s.AfterStashText -NoNewline -BackgroundColor $s.AfterStashBackgroundColor -ForegroundColor $s.AfterStashForegroundColor
    }


    # close git prompt
    Write-Host $arrowSymbol -NoNewLine -BackgroundColor $defaultBackColor -ForegroundColor $gitBackColor
  }
}

function getGitStatus($Path) {
  if (Test-Path -Path (Join-Path $Path '.git') ) {
    $isGitLoaded = Import-GitModule $isGitLoaded
    Write-GitPrompt
    return
  }
  $SplitPath = split-path $path
  if ($SplitPath) {
    getGitStatus($SplitPath)
  }
  else {
    Write-Host $arrowSymbol -NoNewLine -ForegroundColor $pathBackColor
  }
}

function tildaPath($Path) {
  $repoHome = "C:\Dev\Repos"

  if ($Path.ToLower().StartsWith($repoHome.ToLower()) -and $Path.Length -gt $repoHome.Length) {
    return "~" + $Path.SubString($repoHome.Length)
  }


  return $Path.replace($env:USERPROFILE, "~")
}

# Replace the cmder prompt entirely with this.
[ScriptBlock]$CmderPrompt = {
  $tp = tildaPath($pwd.ProviderPath)
  Microsoft.PowerShell.Utility\Write-Host "`n" $tp " " -NoNewLine -BackgroundColor $pathBackColor -ForegroundColor $pathForeColor

  getGitStatus($pwd.ProviderPath)
}


[ScriptBlock]$PostPrompt = {
}

## <Continue to add your own>