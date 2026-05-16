using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.Drawing;
using System.Drawing.Drawing2D;
using System.IO;
using System.Threading.Tasks;
using System.Windows.Forms;

namespace DevTools;

static class Program
{
    [STAThread]
    static void Main()
    {
        ApplicationConfiguration.Initialize();
        Application.Run(new MainForm());
    }
}

// ── Flat button with accent left border ────────────────────────────────────
class AccentBtn : Control
{
    static readonly Color BgNormal = Color.FromArgb(45, 45, 45);
    static readonly Color BgHover  = Color.FromArgb(60, 60, 60);
    static readonly Color BgPress  = Color.FromArgb(35, 35, 35);
    static readonly Color FgText   = Color.FromArgb(204, 204, 204);

    readonly Color _accent;
    bool _hovered, _pressed;

    public AccentBtn(string text, Color accent)
    {
        Text      = text;
        _accent   = accent;
        Size      = new Size(210, 36);
        Cursor    = Cursors.Hand;
        Font      = new Font("Segoe UI", 9f);
        DoubleBuffered = true;

        MouseEnter += (_, _) => { _hovered = true;  Invalidate(); };
        MouseLeave += (_, _) => { _hovered = false; _pressed = false; Invalidate(); };
        MouseDown  += (_, _) => { _pressed = true;  Invalidate(); };
        MouseUp    += (_, e) => { _pressed = false; Invalidate(); };
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        var g = e.Graphics;
        g.SmoothingMode = SmoothingMode.AntiAlias;
        var bg = _pressed ? BgPress : _hovered ? BgHover : BgNormal;
        g.FillRectangle(new SolidBrush(bg), ClientRectangle);
        g.FillRectangle(new SolidBrush(_accent), 0, 0, 3, Height);
        var tf = new StringFormat { Alignment = StringAlignment.Center, LineAlignment = StringAlignment.Center };
        g.DrawString(Text, Font, new SolidBrush(FgText), new Rectangle(3, 0, Width - 3, Height), tf);
    }
}

// ── Custom tab bar (no TabControl = no white borders) ──────────────────────
class TabBar : Panel
{
    public event Action<int>? TabSelected;

    readonly List<Label> _tabs = [];
    int _selected = 0;

    static readonly Color BgBar      = Color.FromArgb(24, 24, 24);
    static readonly Color FgActive   = Color.FromArgb(204, 204, 204);
    static readonly Color FgInactive = Color.FromArgb(100, 100, 100);
    static readonly Color Underline  = Color.FromArgb(0, 122, 204);

    public TabBar(params string[] labels)
    {
        BackColor = BgBar;
        Height    = 32;
        Dock      = DockStyle.Top;

        for (int i = 0; i < labels.Length; i++)
        {
            var idx = i;
            var lbl = new Label
            {
                Text      = labels[i],
                Font      = new Font("Segoe UI", 9f),
                ForeColor = i == 0 ? FgActive : FgInactive,
                TextAlign = ContentAlignment.MiddleCenter,
                Width     = 78,
                Height    = 32,
                Left      = i * 78,
                Cursor    = Cursors.Hand,
                Tag       = i,
            };
            lbl.MouseEnter += (_, _) => { if ((int)lbl.Tag! != _selected) lbl.ForeColor = Color.FromArgb(150, 150, 150); };
            lbl.MouseLeave += (_, _) => { if ((int)lbl.Tag! != _selected) lbl.ForeColor = FgInactive; };
            lbl.Click      += (_, _) => Select(idx);
            _tabs.Add(lbl);
            Controls.Add(lbl);
        }

        // bottom separator
        Controls.Add(new Panel { BackColor = Color.FromArgb(51, 51, 51), Dock = DockStyle.Bottom, Height = 1 });
    }

    public void Select(int idx)
    {
        _selected = idx;
        for (int i = 0; i < _tabs.Count; i++)
            _tabs[i].ForeColor = i == idx ? FgActive : FgInactive;
        Invalidate();
        TabSelected?.Invoke(idx);
    }

    protected override void OnPaint(PaintEventArgs e)
    {
        base.OnPaint(e);
        if (_selected < _tabs.Count)
        {
            var t = _tabs[_selected];
            e.Graphics.FillRectangle(new SolidBrush(Underline), t.Left, Height - 3, t.Width, 2);
        }
    }
}

// ── Main form ──────────────────────────────────────────────────────────────
class MainForm : Form
{
    static readonly string ToolsDir = Path.GetDirectoryName(Application.ExecutablePath)!;

    static readonly Color BgBase   = Color.FromArgb(30, 30, 30);
    static readonly Color BgPanel  = Color.FromArgb(37, 37, 37);
    static readonly Color BgHeader = Color.FromArgb(24, 24, 24);
    static readonly Color BgOutput = Color.FromArgb(12, 12, 12);
    static readonly Color Sep      = Color.FromArgb(51, 51, 51);

    static readonly Color AccBlue   = Color.FromArgb(0,   122, 204);
    static readonly Color AccCyan   = Color.FromArgb(0,   188, 212);
    static readonly Color AccGreen  = Color.FromArgb(76,  175, 80);
    static readonly Color AccRed    = Color.FromArgb(244, 67,  54);
    static readonly Color AccPurple = Color.FromArgb(156, 39,  176);

    RichTextBox _output    = null!;
    Label       _status    = null!;
    Panel       _body      = null!;
    Panel       _queueView = null!;
    Label       _queueBtn  = null!;
    bool        _running;
    string      _currentScript = "";
    readonly Queue<(string script, bool admin)> _queue = new();

    public MainForm()
    {
        Text            = "Dev Tools";
        BackColor       = BgBase;
        ForeColor       = Color.FromArgb(204, 204, 204);
        Font            = new Font("Segoe UI", 9f);
        FormBorderStyle = FormBorderStyle.FixedSingle;
        MaximizeBox     = false;
        StartPosition   = FormStartPosition.CenterScreen;
        Width           = 820;
        Height          = 580;

        GenerateComboBats();
        Build();
    }

    void Build()
    {
        var root = new TableLayoutPanel
        {
            Dock        = DockStyle.Fill,
            RowCount    = 2,
            ColumnCount = 1,
            BackColor   = BgBase,
            Padding     = Padding.Empty,
            Margin      = Padding.Empty,
        };
        root.RowStyles.Add(new RowStyle(SizeType.Absolute, 52));
        root.RowStyles.Add(new RowStyle(SizeType.Percent, 100));

        root.Controls.Add(BuildHeader(), 0, 0);

        // split: left = tabs+content, right = output
        var split = new SplitContainer
        {
            Dock            = DockStyle.Fill,
            Orientation     = Orientation.Vertical,
            SplitterWidth   = 1,
            BackColor       = Sep,
            IsSplitterFixed = false,
        };
        Load += (_, _) =>
        {
            split.Panel1MinSize    = 390;
            split.Panel2MinSize    = 200;
            try { split.SplitterDistance = 460; }
            catch { split.SplitterDistance = split.Width * 6 / 10; }
        };
        split.Panel1.BackColor = BgPanel;
        split.Panel2.BackColor = BgOutput;

        // LEFT: tab bar + pages
        var tabs = new TabBar("Manten.", "Docker", "Dev", "Seguridad", "Combos");
        _body = new Panel { Dock = DockStyle.Fill, BackColor = BgPanel };

        var pages = new Panel[]
        {
            TabContent(AccBlue,
                Btn("Disk Summary",         "disk_summary.bat",         AccBlue, "Resumen de espacio en todos los discos"),
                Btn("Limpiar Temp",         "clean_temp.bat",           AccBlue, "Borra Temp, npm cache, Chrome cache"),
                Btn("Archivos Grandes",     "find_large_files.bat",     AccBlue, "Top 30 archivos >100MB en C:\\Users"),
                Btn("node_modules Cleaner", "node_modules_cleaner.bat", AccBlue, "Busca y borra carpetas node_modules"),
                Btn("pip Cache Clean",      "pip_cache_clean.bat",      AccBlue, "Limpia cache de pip y uv"),
                Btn("VS Code Cleanup",      "vscode_cleanup.bat",       AccBlue, "Borra cache y logs de VS Code"),
                Btn("Git Cleanup",          "git_cleanup.bat",          AccBlue, "Git GC y prune en todos los repos")),
            TabContent(AccCyan,
                Btn("Docker Prune",           "docker_prune.bat",       AccCyan, "Borra contenedores parados y build cache"),
                Btn("Compact Docker (Admin)", "compact_docker.bat",     AccCyan, "Compacta .vhdx — requiere Admin", admin: true),
                Btn("WSL Memory Reclaim",     "wsl_memory_reclaim.bat", AccCyan, "Apaga WSL2 y libera RAM")),
            TabContent(AccGreen,
                Btn("Dev Env Check",  "dev_env_check.bat",         AccGreen, "Versiones de Node, Python, Git, Docker..."),
                Btn("Port Killer",    "port_killer.bat",           AccGreen, "Mata un proceso por número de puerto"),
                Btn("Network Check",  "network_check.bat",         AccGreen, "IP local/pública, DNS, puertos abiertos"),
                Btn("Startup Check",  "startup_check.bat",         AccGreen, "Muestra qué programas arrancan con Windows"),
                Btn("Move + Symlink", "move_to_drive_symlink.bat", AccGreen, "Mueve carpeta a otro disco y deja junction")),
            TabContent(AccRed,
                Btn("Security Check",    "security_check.bat",    AccRed, "Firewall, Defender, puertos, usuarios"),
                Btn("Secrets Scan",      "secrets_scan.bat",      AccRed, "Busca .env y credenciales en disco"),
                Btn("Git Secrets Audit", "git_secrets_audit.bat", AccRed, "Verifica .gitignore y historial git por secrets")),
            TabContent(AccPurple,
                Btn("Mantenimiento Completo", "_combo_maint.bat", AccPurple, "Temp + node_modules + pip + VSCode + git + docker prune"),
                Btn("Limpieza Profunda",      "_combo_deep.bat",  AccPurple, "Todo lo anterior + compact Docker (Admin)", admin: true),
                Btn("Auditoría Seguridad",    "_combo_audit.bat", AccPurple, "Secrets scan + security check + git audit")),
        };

        foreach (var pg in pages) { pg.Visible = false; pg.Dock = DockStyle.Fill; _body.Controls.Add(pg); }
        pages[0].Visible = true;
        tabs.TabSelected += idx => { foreach (var pg in pages) pg.Visible = false; pages[idx].Visible = true; };

        var leftLayout = new TableLayoutPanel
        {
            Dock        = DockStyle.Fill,
            RowCount    = 2,
            ColumnCount = 1,
            BackColor   = BgPanel,
            Padding     = Padding.Empty,
            Margin      = Padding.Empty,
        };
        leftLayout.RowStyles.Add(new RowStyle(SizeType.Absolute, 33));
        leftLayout.RowStyles.Add(new RowStyle(SizeType.Percent, 100));
        leftLayout.Controls.Add(tabs,  0, 0);
        leftLayout.Controls.Add(_body, 0, 1);
        split.Panel1.Controls.Add(leftLayout);

        // RIGHT: output
        split.Panel2.Controls.Add(BuildOutput());

        root.Controls.Add(split, 0, 1);
        Controls.Add(root);
    }

    Panel BuildHeader()
    {
        var p = new Panel { Dock = DockStyle.Fill, BackColor = BgHeader };
        p.Controls.Add(new Label { Text = "Dev Tools", ForeColor = Color.FromArgb(204,204,204), Font = new Font("Segoe UI", 13f), AutoSize = true, Location = new Point(16, 10) });
        p.Controls.Add(new Label { Text = "maintenance & dev utilities", ForeColor = Color.FromArgb(80,80,80), Font = new Font("Segoe UI", 8f), AutoSize = true, Location = new Point(18, 32) });
        p.Controls.Add(new Panel { BackColor = Sep, Dock = DockStyle.Bottom, Height = 1 });
        return p;
    }

    Panel TabContent(Color accent, params AccentBtn[] buttons)
    {
        var wrap = new Panel { BackColor = BgPanel };
        var strip = new Panel { BackColor = accent, Width = 2, Dock = DockStyle.Left };
        var flow = new FlowLayoutPanel
        {
            FlowDirection = FlowDirection.LeftToRight,
            WrapContents  = true,
            BackColor     = BgPanel,
            Padding       = new Padding(14, 12, 0, 0),
            Dock          = DockStyle.Fill,
        };
        foreach (var b in buttons) { b.Margin = new Padding(0, 0, 8, 8); flow.Controls.Add(b); }
        wrap.Controls.Add(flow);
        wrap.Controls.Add(strip);
        return wrap;
    }

    AccentBtn Btn(string label, string script, Color accent, string tip, bool admin = false)
    {
        var btn = new AccentBtn(label, accent);
        new ToolTip { InitialDelay = 400 }.SetToolTip(btn, tip);
        btn.Click += (_, _) => RunTool(script, admin);
        return btn;
    }

    Panel BuildOutput()
    {
        var p = new Panel { Dock = DockStyle.Fill, BackColor = BgOutput };

        // ── header bar ────────────────────────────────────────────────────
        var header = new Panel { Dock = DockStyle.Top, Height = 24, BackColor = Color.FromArgb(20,20,20) };
        var titleLbl = new Label { Text = "OUTPUT", ForeColor = Color.FromArgb(75,75,75), Font = new Font("Segoe UI", 7.5f, FontStyle.Bold), AutoSize = true, Location = new Point(10, 5) };
        header.Controls.Add(titleLbl);

        _queueBtn = new Label { Text = "queue", ForeColor = Color.FromArgb(75,75,75), Font = new Font("Segoe UI", 7.5f), AutoSize = true, Cursor = Cursors.Hand, Location = new Point(9999, 5) };
        _queueBtn.Click      += (_, _) => ToggleQueueView();
        _queueBtn.MouseEnter += (_, _) => { if (_queueBtn.Tag is not true) _queueBtn.ForeColor = Color.FromArgb(204,204,204); };
        _queueBtn.MouseLeave += (_, _) => { if (_queueBtn.Tag is not true) _queueBtn.ForeColor = Color.FromArgb(75,75,75); };
        header.Controls.Add(_queueBtn);

        var logsLbl = new Label { Text = "logs", ForeColor = Color.FromArgb(75,75,75), Font = new Font("Segoe UI", 7.5f), AutoSize = true, Cursor = Cursors.Hand, Location = new Point(9999, 5) };
        logsLbl.Click      += (_, _) => { var d = Path.Combine(ToolsDir,"logs"); Directory.CreateDirectory(d); Process.Start("explorer.exe", d); };
        logsLbl.MouseEnter += (_, _) => logsLbl.ForeColor = Color.FromArgb(204,204,204);
        logsLbl.MouseLeave += (_, _) => logsLbl.ForeColor = Color.FromArgb(75,75,75);
        header.Controls.Add(logsLbl);

        var clearLbl = new Label { Text = "clear", ForeColor = Color.FromArgb(75,75,75), Font = new Font("Segoe UI", 7.5f), AutoSize = true, Cursor = Cursors.Hand, Location = new Point(9999, 5) };
        clearLbl.Click      += (_, _) => _output.Clear();
        clearLbl.MouseEnter += (_, _) => clearLbl.ForeColor = Color.FromArgb(204,204,204);
        clearLbl.MouseLeave += (_, _) => clearLbl.ForeColor = Color.FromArgb(75,75,75);
        header.Controls.Add(clearLbl);

        header.Layout += (_, _) => {
            clearLbl.Left  = header.Width - clearLbl.Width - 10;
            logsLbl.Left   = clearLbl.Left - logsLbl.Width - 14;
            _queueBtn.Left = logsLbl.Left  - _queueBtn.Width - 14;
        };
        header.Controls.Add(new Panel { BackColor = Sep, Dock = DockStyle.Bottom, Height = 1 });

        // ── output richtext ───────────────────────────────────────────────
        _output = new RichTextBox
        {
            Dock        = DockStyle.Fill,
            BackColor   = BgOutput,
            ForeColor   = Color.FromArgb(180,180,180),
            Font        = new Font("Consolas", 8.5f),
            ReadOnly    = true,
            BorderStyle = BorderStyle.None,
            ScrollBars  = RichTextBoxScrollBars.Vertical,
            Padding     = new Padding(8),
        };

        // ── queue view panel (hidden by default) ──────────────────────────
        _queueView = new Panel { Dock = DockStyle.Fill, BackColor = Color.FromArgb(18,18,18), Visible = false, Padding = new Padding(14,10,14,10) };

        // ── status bar ────────────────────────────────────────────────────
        _status = new Label
        {
            Dock      = DockStyle.Bottom,
            Height    = 20,
            BackColor = Color.FromArgb(0,122,204),
            ForeColor = Color.White,
            Font      = new Font("Segoe UI", 8f),
            TextAlign = ContentAlignment.MiddleLeft,
            Padding   = new Padding(10,0,0,0),
            Text      = "  Ready",
        };

        p.Controls.Add(_output);
        p.Controls.Add(_queueView);
        p.Controls.Add(header);
        p.Controls.Add(_status);
        return p;
    }

    void ToggleQueueView()
    {
        var show = !_queueView.Visible;
        _queueView.Visible = show;
        _output.Visible    = !show;
        _queueBtn.Tag      = show;   // mark active
        _queueBtn.ForeColor = show ? Color.FromArgb(0,122,204) : Color.FromArgb(75,75,75);
        if (show) RefreshQueueView();
    }

    void RefreshQueueView()
    {
        if (!_queueView.Visible) return;
        _queueView.Controls.Clear();

        var items = new List<(string text, Color color, bool bold)>();

        if (_running && _currentScript != "")
            items.Add(($"▶  {_currentScript}", Color.FromArgb(0,188,100), true));
        else
            items.Add(("  idle", Color.FromArgb(75,75,75), false));

        var pending = _queue.ToArray();
        if (pending.Length == 0 && !_running)
        {
            items.Add(("", Color.FromArgb(75,75,75), false));
            items.Add(("  no items queued", Color.FromArgb(60,60,60), false));
        }
        else
        {
            for (int i = 0; i < pending.Length; i++)
                items.Add(($"  {i+1}.  {pending[i].script}{(pending[i].admin ? "  [admin]" : "")}", Color.FromArgb(120,120,120), false));
        }

        int y = 10;
        foreach (var (text, color, bold) in items)
        {
            if (text == "") { y += 8; continue; }
            var lbl = new Label
            {
                Text      = text,
                ForeColor = color,
                Font      = new Font("Consolas", 9f, bold ? FontStyle.Bold : FontStyle.Regular),
                AutoSize  = false,
                Width     = _queueView.Width - 28,
                Height    = 22,
                Location  = new Point(14, y),
            };
            _queueView.Controls.Add(lbl);
            y += 24;
        }

        // clear-queue link at bottom
        if (_queue.Count > 0)
        {
            var clr = new Label { Text = "clear queue", ForeColor = Color.FromArgb(183,28,28), Font = new Font("Segoe UI", 8f), AutoSize = true, Cursor = Cursors.Hand, Location = new Point(14, y + 8) };
            clr.Click += (_, _) => { _queue.Clear(); RefreshQueueView(); UpdateQueueBtn(); };
            _queueView.Controls.Add(clr);
        }
    }

    void UpdateQueueBtn()
    {
        var n = _queue.Count;
        _queueBtn.Text = n > 0 ? $"queue ({n})" : "queue";
        _queueBtn.ForeColor = (_queueBtn.Tag is true)
            ? Color.FromArgb(0,122,204)
            : (n > 0 ? Color.FromArgb(255,183,77) : Color.FromArgb(75,75,75));
    }

    void RunTool(string script, bool asAdmin)
    {
        var path = Path.Combine(ToolsDir, script);
        if (!File.Exists(path)) { AppendOutput($"[error] not found: {script}\n", Color.FromArgb(244,67,54)); return; }

        if (asAdmin)
        {
            SetStatus($"  Running (Admin): {script}");
            Process.Start(new ProcessStartInfo("cmd.exe", $"/c \"{path}\"") { UseShellExecute = true, Verb = "runas" });
            AppendOutput($"[admin] {script} — opened in separate window\n", Color.FromArgb(255,183,77));
            return;
        }

        if (_running)
        {
            _queue.Enqueue((script, asAdmin));
            UpdateQueueBtn();
            RefreshQueueView();
            SetStatus($"  Running… +{_queue.Count} queued");
            AppendOutput($"  ↳ queued [{_queue.Count}]: {script}\n", Color.FromArgb(120,120,120));
            return;
        }

        ExecuteScript(script);
    }

    void ExecuteScript(string script)
    {
        var path = Path.Combine(ToolsDir, script);
        _currentScript = script;
        SetStatus($"  Running: {script}{(_queue.Count > 0 ? $"  [{_queue.Count} queued]" : "")}");
        AppendOutput($"\n▶  {script}\n", Color.FromArgb(0,122,204));
        _running = true;
        RefreshQueueView();

        var logDir  = Path.Combine(ToolsDir, "logs");
        Directory.CreateDirectory(logDir);
        var logPath = Path.Combine(logDir, $"{DateTime.Now:yyyy-MM-dd_HH-mm-ss}_{Path.GetFileNameWithoutExtension(script)}.txt");
        var logBuf  = new System.Text.StringBuilder();
        logBuf.AppendLine($"▶ {script}  [{DateTime.Now:yyyy-MM-dd HH:mm:ss}]");

        Task.Run(() =>
        {
            var psi = new ProcessStartInfo("cmd.exe", $"/c \"{path}\"")
            {
                UseShellExecute        = false,
                RedirectStandardOutput = true,
                RedirectStandardError  = true,
                CreateNoWindow         = true,
            };
            using var proc = Process.Start(psi)!;
            proc.OutputDataReceived += (_, e) => { if (e.Data != null) { AppendOutput(e.Data + "\n"); logBuf.AppendLine(e.Data); } };
            proc.ErrorDataReceived  += (_, e) => { if (e.Data != null) { AppendOutput(e.Data + "\n", Color.FromArgb(244,67,54)); logBuf.AppendLine("[ERR] " + e.Data); } };
            proc.BeginOutputReadLine();
            proc.BeginErrorReadLine();
            proc.WaitForExit();
            logBuf.AppendLine($"■ exit {proc.ExitCode}  [{DateTime.Now:HH:mm:ss}]");
            File.WriteAllText(logPath, logBuf.ToString(), System.Text.Encoding.UTF8);
            Invoke(() =>
            {
                _running = false;
                _currentScript = "";
                var ok = proc.ExitCode == 0;
                _status.BackColor = ok ? Color.FromArgb(0,122,204) : Color.FromArgb(183,28,28);
                AppendOutput($"■  exit {proc.ExitCode}  →  logs\\{Path.GetFileName(logPath)}\n",
                    ok ? Color.FromArgb(76,175,80) : Color.FromArgb(244,67,54));

                if (_queue.Count > 0)
                {
                    var (next, nextAdmin) = _queue.Dequeue();
                    UpdateQueueBtn();
                    RefreshQueueView();
                    if (nextAdmin) RunTool(next, true);
                    else           ExecuteScript(next);
                }
                else
                {
                    SetStatus($"  Done: {script}  —  exit {proc.ExitCode}");
                    UpdateQueueBtn();
                    RefreshQueueView();
                }
            });
        });
    }

    void AppendOutput(string text, Color? color = null)
    {
        if (InvokeRequired) { Invoke(() => AppendOutput(text, color)); return; }
        _output.SelectionStart  = _output.TextLength;
        _output.SelectionLength = 0;
        _output.SelectionColor  = color ?? Color.FromArgb(180,180,180);
        _output.AppendText(text);
        _output.ScrollToCaret();
    }

    void SetStatus(string msg)
    {
        if (InvokeRequired) { Invoke(() => SetStatus(msg)); return; }
        _status.Text = msg;
    }

    static void GenerateComboBats()
    {
        WriteBat("_combo_maint.bat", "clean_temp.bat","node_modules_cleaner.bat","pip_cache_clean.bat","vscode_cleanup.bat","git_cleanup.bat","docker_prune.bat");
        WriteBat("_combo_deep.bat",  "clean_temp.bat","node_modules_cleaner.bat","pip_cache_clean.bat","vscode_cleanup.bat","git_cleanup.bat","docker_prune.bat","compact_docker.bat");
        WriteBat("_combo_audit.bat", "secrets_scan.bat","security_check.bat","git_secrets_audit.bat");
    }

    static void WriteBat(string name, params string[] scripts)
    {
        var path = Path.Combine(ToolsDir, name);
        var sb   = new System.Text.StringBuilder("@echo off\r\n");
        foreach (var s in scripts) sb.AppendLine($"call \"%~dp0{s}\"");
        File.WriteAllText(path, sb.ToString());
    }
}
