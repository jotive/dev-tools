Add-Type -AssemblyName System.Windows.Forms
Add-Type -AssemblyName System.Drawing

$TOOLS = Split-Path -Parent $MyInvocation.MyCommand.Path

function Run-Tool($script, $asAdmin = $false) {
    $path = Join-Path $TOOLS $script
    if ($asAdmin) {
        Start-Process "cmd.exe" -ArgumentList "/c `"$path`"" -Verb RunAs
    } else {
        Start-Process "cmd.exe" -ArgumentList "/c `"$path`""
    }
}

# --- Form ---
$form = New-Object System.Windows.Forms.Form
$form.Text = "Dev Tools"
$form.Size = New-Object System.Drawing.Size(520, 680)
$form.StartPosition = "CenterScreen"
$form.BackColor = [System.Drawing.Color]::FromArgb(18, 18, 18)
$form.ForeColor = [System.Drawing.Color]::White
$form.Font = New-Object System.Drawing.Font("Segoe UI", 9)
$form.FormBorderStyle = "FixedSingle"
$form.MaximizeBox = $false

function New-Label($text, $x, $y, $w = 460, $h = 22) {
    $l = New-Object System.Windows.Forms.Label
    $l.Text = $text
    $l.Location = New-Object System.Drawing.Point($x, $y)
    $l.Size = New-Object System.Drawing.Size($w, $h)
    $l.ForeColor = [System.Drawing.Color]::FromArgb(120, 120, 120)
    $l.Font = New-Object System.Drawing.Font("Segoe UI", 8, [System.Drawing.FontStyle]::Bold)
    return $l
}

function New-Btn($text, $x, $y, $w = 210, $color = "2196F3") {
    $btn = New-Object System.Windows.Forms.Button
    $btn.Text = $text
    $btn.Location = New-Object System.Drawing.Point($x, $y)
    $btn.Size = New-Object System.Drawing.Size($w, 32)
    $btn.FlatStyle = "Flat"
    $btn.FlatAppearance.BorderSize = 0
    $btn.BackColor = [System.Drawing.ColorTranslator]::FromHtml("#$color")
    $btn.ForeColor = [System.Drawing.Color]::White
    $btn.Font = New-Object System.Drawing.Font("Segoe UI", 9)
    $btn.Cursor = [System.Windows.Forms.Cursors]::Hand
    return $btn
}

$y = 15

# --- MANTENIMIENTO ---
$form.Controls.Add((New-Label "  MANTENIMIENTO" 20 $y))
$y += 24

$btn_disk = New-Btn "Disk Summary" 20 $y 210 "37474F"
$btn_disk.Add_Click({ Run-Tool "disk_summary.bat" })
$form.Controls.Add($btn_disk)

$btn_temp = New-Btn "Limpiar Temp" 240 $y 210 "37474F"
$btn_temp.Add_Click({ Run-Tool "clean_temp.bat" })
$form.Controls.Add($btn_temp)
$y += 38

$btn_large = New-Btn "Archivos Grandes" 20 $y 210 "37474F"
$btn_large.Add_Click({ Run-Tool "find_large_files.bat" })
$form.Controls.Add($btn_large)

$btn_nm = New-Btn "node_modules Cleaner" 240 $y 210 "37474F"
$btn_nm.Add_Click({ Run-Tool "node_modules_cleaner.bat" })
$form.Controls.Add($btn_nm)
$y += 38

$btn_pip = New-Btn "pip Cache Clean" 20 $y 210 "37474F"
$btn_pip.Add_Click({ Run-Tool "pip_cache_clean.bat" })
$form.Controls.Add($btn_pip)

$btn_vsc = New-Btn "VS Code Cleanup" 240 $y 210 "37474F"
$btn_vsc.Add_Click({ Run-Tool "vscode_cleanup.bat" })
$form.Controls.Add($btn_vsc)
$y += 38

$btn_git = New-Btn "Git Cleanup" 20 $y 210 "37474F"
$btn_git.Add_Click({ Run-Tool "git_cleanup.bat" })
$form.Controls.Add($btn_git)
$y += 46

# --- DOCKER / WSL ---
$form.Controls.Add((New-Label "  DOCKER / WSL" 20 $y))
$y += 24

$btn_prune = New-Btn "Docker Prune" 20 $y 210 "1565C0"
$btn_prune.Add_Click({ Run-Tool "docker_prune.bat" })
$form.Controls.Add($btn_prune)

$btn_compact = New-Btn "Compact Docker (Admin)" 240 $y 210 "0D47A1"
$btn_compact.Add_Click({ Run-Tool "compact_docker.bat" $true })
$form.Controls.Add($btn_compact)
$y += 38

$btn_wsl = New-Btn "WSL Memory Reclaim" 20 $y 210 "1565C0"
$btn_wsl.Add_Click({ Run-Tool "wsl_memory_reclaim.bat" })
$form.Controls.Add($btn_wsl)
$y += 46

# --- DEV ---
$form.Controls.Add((New-Label "  DEV" 20 $y))
$y += 24

$btn_env = New-Btn "Dev Env Check" 20 $y 210 "2E7D32"
$btn_env.Add_Click({ Run-Tool "dev_env_check.bat" })
$form.Controls.Add($btn_env)

$btn_port = New-Btn "Port Killer" 240 $y 210 "2E7D32"
$btn_port.Add_Click({ Run-Tool "port_killer.bat" })
$form.Controls.Add($btn_port)
$y += 38

$btn_net = New-Btn "Network Check" 20 $y 210 "2E7D32"
$btn_net.Add_Click({ Run-Tool "network_check.bat" })
$form.Controls.Add($btn_net)

$btn_startup = New-Btn "Startup Check" 240 $y 210 "2E7D32"
$btn_startup.Add_Click({ Run-Tool "startup_check.bat" })
$form.Controls.Add($btn_startup)
$y += 38

$btn_sym = New-Btn "Move + Symlink" 20 $y 210 "2E7D32"
$btn_sym.Add_Click({ Run-Tool "move_to_drive_symlink.bat" })
$form.Controls.Add($btn_sym)
$y += 46

# --- SEGURIDAD ---
$form.Controls.Add((New-Label "  SEGURIDAD" 20 $y))
$y += 24

$btn_sec = New-Btn "Security Check" 20 $y 210 "B71C1C"
$btn_sec.Add_Click({ Run-Tool "security_check.bat" })
$form.Controls.Add($btn_sec)

$btn_scan = New-Btn "Secrets Scan" 240 $y 210 "B71C1C"
$btn_scan.Add_Click({ Run-Tool "secrets_scan.bat" })
$form.Controls.Add($btn_scan)
$y += 38

$btn_gsa = New-Btn "Git Secrets Audit" 20 $y 210 "B71C1C"
$btn_gsa.Add_Click({ Run-Tool "git_secrets_audit.bat" })
$form.Controls.Add($btn_gsa)
$y += 46

# --- COMBOS ---
$form.Controls.Add((New-Label "  COMBOS" 20 $y))
$y += 24

$btn_maint = New-Btn "Mantenimiento Completo" 20 $y 210 "6A1B9A"
$btn_maint.Add_Click({
    Run-Tool "clean_temp.bat"
    Run-Tool "node_modules_cleaner.bat"
    Run-Tool "pip_cache_clean.bat"
    Run-Tool "vscode_cleanup.bat"
    Run-Tool "git_cleanup.bat"
    Run-Tool "docker_prune.bat"
})
$form.Controls.Add($btn_maint)

$btn_deep = New-Btn "Limpieza Profunda (Admin)" 240 $y 210 "4A148C"
$btn_deep.Add_Click({
    Run-Tool "clean_temp.bat"
    Run-Tool "node_modules_cleaner.bat"
    Run-Tool "pip_cache_clean.bat"
    Run-Tool "vscode_cleanup.bat"
    Run-Tool "git_cleanup.bat"
    Run-Tool "docker_prune.bat"
    Run-Tool "compact_docker.bat" $true
})
$form.Controls.Add($btn_deep)
$y += 38

$btn_audit = New-Btn "Auditoria Seguridad" 20 $y 210 "880E4F"
$btn_audit.Add_Click({
    Run-Tool "secrets_scan.bat"
    Run-Tool "security_check.bat"
    Run-Tool "git_secrets_audit.bat"
})
$form.Controls.Add($btn_audit)

$form.Size = New-Object System.Drawing.Size(470, ($y + 80))
[System.Windows.Forms.Application]::Run($form)
