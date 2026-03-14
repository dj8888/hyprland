# buildPDF and Mermaid

The `hypr/scripts/buildPDF` script builds PDFs from Markdown with `pandoc -d prd`. It uses a **Pandoc defaults file** and a **Mermaid Lua filter**. These live in Pandoc’s user data directory, not in this repo. On a new system you need to create them once.

## 1. Pandoc user data directory

Pandoc looks under (see `pandoc --version`):

- **User data dir:** `~/.local/share/pandoc/`

Create:

- `~/.local/share/pandoc/defaults/`
- `~/.local/share/pandoc/filters/`
- `~/.local/share/pandoc/includes/`

## 2. Defaults file: `prd`

Create **`~/.local/share/pandoc/defaults/prd.yaml`** (or `prd.yml`):

```yaml
pdf-engine: xelatex
standalone: true
toc: true
toc-depth: 3
number-sections: false
highlight-style: tango
filters:
  - mermaid.lua
include-in-header:
  - /home/YOUR_USER/.local/share/pandoc/includes/prd-header.tex
variables:
  geometry: "a4paper, margin=0.8in"
  fontsize: "10pt"
  documentclass: "article"
  colorlinks: true
  linkcolor: "blue"
  urlcolor: "blue"
  toccolor: "blue"
  mainfont: "Noto Serif"
  sansfont: "Noto Sans"
  monofont: "Noto Sans Mono"
```

Replace `YOUR_USER` in the `include-in-header` path with your actual username (or use a path that works on your machine).

**Optional — `==highlighted text==` in the PDF:** To have Pandoc treat `==...==` as highlighted text (like the Markdown preview), you need (1) the **mark** reader and (2) the **soul** LaTeX package. Add `reader: markdown+mark` to `prd.yaml` (or run pandoc with `-f markdown+mark` in the script). Then install soul so LaTeX can find `soul.sty`. On Arch with TeX Live: install `texlive-bin` (for `tlmgr`) if needed, then run `tlmgr install soul`. Without soul, the PDF build will fail with “File soul.sty not found” if you enable the mark extension.

## 3. LaTeX header: `prd-header.tex`

Create **`~/.local/share/pandoc/includes/prd-header.tex`**:

```tex
% Required for mermaid diagram images (raw LaTeX inclusion)
\usepackage{graphicx}

% Wrap long lines in code blocks instead of clipping
\usepackage{fvextra}
\DefineVerbatimEnvironment{Highlighting}{Verbatim}{
  breaklines,
  breakanywhere,
  commandchars=\\\{\}
}

% Smaller font in tables to prevent wide tables from overflowing
\usepackage{etoolbox}
\AtBeginEnvironment{longtable}{\small}

% Give LaTeX more flexibility with line breaks to avoid overfull hboxes
\tolerance=1000
\emergencystretch=3em
```

Requires TeX packages: `graphicx`, `fvextra`, `etoolbox` (usually with texlive-latexextra).

## 4. Mermaid Lua filter: `mermaid.lua`

The filter **`~/.local/share/pandoc/filters/mermaid.lua`** turns Mermaid code blocks (e.g. ` ```mermaid `) into images in the PDF. It uses **`mmdc`** from `@mermaid-js/mermaid-cli`.

- **Install mmdc** (Node/npm):

  ```bash
  npm install -g --prefix=$HOME/.local @mermaid-js/mermaid-cli
  ```

  Ensure `~/.local/bin` is on your `PATH` (this repo’s zsh config adds it).

- **Copy the filter:** save the following as **`~/.local/share/pandoc/filters/mermaid.lua`**. It looks for `mmdc` in `PATH` or `~/.local/bin/mmdc`, renders Mermaid blocks to PNG under `/tmp/pandoc-mermaid`, and embeds them in the PDF.

```lua
-- mermaid.lua — Pandoc Lua filter that renders Mermaid code blocks to images
-- Requires: @mermaid-js/mermaid-cli (mmdc)

local system = require("pandoc.system")

local img_dir = "/tmp/pandoc-mermaid"
os.execute("mkdir -p '" .. img_dir .. "'")

local function file_exists(path)
  local f = io.open(path, "rb")
  if f then f:close() return true end
  return false
end

local mmdc_bin = nil
local function find_mmdc()
  if mmdc_bin ~= nil then return mmdc_bin end

  local candidates = {
    "mmdc",
    (os.getenv("HOME") or "") .. "/.local/bin/mmdc",
  }

  for _, cmd in ipairs(candidates) do
    local handle = io.popen(cmd .. " --version 2>/dev/null")
    if handle then
      local out = handle:read("*a")
      handle:close()
      if out and out:match("%d") then
        mmdc_bin = cmd
        return mmdc_bin
      end
    end
  end

  mmdc_bin = false
  io.stderr:write("[mermaid.lua] mmdc not found — mermaid blocks will render as code.\n")
  io.stderr:write("[mermaid.lua] Install: npm install -g --prefix=$HOME/.local @mermaid-js/mermaid-cli\n")
  return false
end

local puppeteer_config = os.getenv("MMDC_PUPPETEER_CONFIG")
  or (os.getenv("HOME") or "") .. "/.config/mermaid/puppeteer-config.json"

function CodeBlock(block)
  if not block.classes:includes("mermaid") then return nil end

  local mmdc = find_mmdc()
  if not mmdc then return nil end

  return system.with_temporary_directory("mermaid", function(tmpdir)
    local infile = tmpdir .. "/input.mmd"
    local outfile = tmpdir .. "/output.png"

    local f = io.open(infile, "w")
    f:write(block.text)
    f:close()

    local cmd = string.format(
      "%s -i '%s' -o '%s' --scale 3 --width 4096 --backgroundColor transparent",
      mmdc, infile, outfile
    )
    if file_exists(puppeteer_config) then
      cmd = cmd .. string.format(" -p '%s'", puppeteer_config)
    end
    cmd = cmd .. " 2>/dev/null"

    os.execute(cmd)

    if file_exists(outfile) then
      local img = io.open(outfile, "rb")
      local data = img:read("*a")
      img:close()

      local hash = pandoc.sha1(block.text)
      local img_path = img_dir .. "/" .. hash .. ".png"
      local out = io.open(img_path, "wb")
      out:write(data)
      out:close()

      if FORMAT:match("latex") or FORMAT:match("pdf") then
        return pandoc.RawBlock("latex",
          "\\begin{center}\n" ..
          "\\includegraphics[width=\\linewidth,height=0.85\\textheight,keepaspectratio]{" .. img_path .. "}\n" ..
          "\\end{center}"
        )
      end

      local attr = pandoc.Attr("", {}, {{"width", "100%"}})
      return pandoc.Para({ pandoc.Image({}, img_path, "", attr) })
    end

    io.stderr:write("[mermaid.lua] Failed to render a diagram, keeping as code block\n")
    return nil
  end)
end
```

- **Optional:** if you use a custom Puppeteer config for mmdc, set `MMDC_PUPPETEER_CONFIG` or place config at `~/.config/mermaid/puppeteer-config.json`; the filter will use it if present.

## 5. Using buildPDF

- Ensure `~/.config/hypr/scripts` is on your `PATH` (this repo’s `.zprofile` adds it), or call by path:

  ```bash
  buildPDF path/to/file.md
  ```

- The script runs `pandoc -d prd file.md -o file.pdf` and opens the PDF in Zathura. Mermaid blocks in `file.md` are rendered to images and included in the PDF.
