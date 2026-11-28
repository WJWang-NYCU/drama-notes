#!/usr/bin/env ruby
# Converts the supplied LaTeX guide to a readable, linked HTML transcript.
require "cgi"

tex = STDIN.read
body = tex[/\\begin\{document\}(.*)\\end\{document\}/m, 1] || abort("No LaTeX document body found")
sources = tex.scan(/\\source\{(\d+)\}\{([^}]*)\}\{([^}]*)\}/).map { |number, url, label| [number, url, label] }

def inline(text)
  value = CGI.escapeHTML(text)
  value.gsub!(/\\fontsize\{[^{}]*\}\{[^{}]*\}/, '')
  value.gsub!(/\\(?:sffamily|bfseries|selectfont|englishfont|raggedright|large|small|normalsize)\b/, '')
  value.gsub!(/\\color\{[^{}]*\}/, '')
  value.gsub!(/\\src\{(\d+)\}/, '<a class="citation" href="#source-\\1">[\\1]</a>')
  value.gsub!(/\\href\{([^}]*)\}\{([^}]*)\}/, '<a href="\\1" target="_blank" rel="noreferrer">\\2</a>')
  value.gsub!(/\\hyperref\[([^\]]*)\]\{([^}]*)\}/, '<a href="#\\1">\\2</a>')
  value.gsub!(/\\textbf\{([^{}]*)\}/, '<strong>\\1</strong>')
  value.gsub!(/\\en\{([^{}]*)\}/, '<i>\\1</i>')
  value.gsub!(/\\underline\{[^{}]*\}/, '＿＿＿＿＿＿')
  value.gsub!(/\\quad/, '　')
  value.gsub!(/\\%/, '%')
  value.gsub!(/\\&/, '&amp;')
  value.gsub!(/\\/, '')
  value.gsub!(/[{}]/, '')
  value
end

paragraphs = []
body.gsub!(/\\source\{\d+\}\{[^}]*\}\{[^}]*\}/, "")
body.lines.each do |line|
  line = line.strip
  next if line.empty? || line.start_with?("%")
  next if line.match?(/\\(?:thispagestyle|vspace|hfill|noindent|small|large|color|linespread|setlength|renewcommand|begingroup|endgroup|makebox|phantomsection|label)/)
  next if line.match?(/\\(?:begin|end)\{(?:minipage|center|tabularx|tabular)\}/)
  next if line.match?(/\\(?:includegraphics|graphicspath|newpage)/)

  if (match = line.match(/\\pageheading\{([^}]*)\}\{([^}]*)\}/))
    paragraphs << %(<h2 id="#{match[1]}">#{inline(match[2])}</h2>)
  elsif (match = line.match(/\\subhead\{(.*)\}/))
    paragraphs << %(<h3>#{inline(match[1])}</h3>)
  elsif (match = line.match(/\\season\{([^}]*)\}\{([^}]*)\}/))
    paragraphs << %(<h3 class="season"><span>#{inline(match[1])}</span>#{inline(match[2])}</h3>)
  elsif (match = line.match(/\\captiontext\{(.*)\}/))
    paragraphs << %(<p class="caption">#{inline(match[1])}</p>)
  elsif (match = line.match(/\\note\{(.*)\}/))
    paragraphs << %(<aside>#{inline(match[1])}</aside>)
  elsif (match = line.match(/\\engpara\{(.*)\}/))
    paragraphs << %(<p class="english">#{inline(match[1].gsub(/\\par/, "<br>"))}</p>)
  elsif line.match?(/^[{}\\]+$/)
    next
  else
    cleaned = inline(line.gsub(/\\par/, "%%BR%%").gsub(/\\\\/, "%%BR%%").gsub(/\s*&\s*/, "　—　")).gsub("%%BR%%", "<br>")
    paragraphs << "<p>#{cleaned}</p>" unless cleaned.empty?
  end
end

html = <<~HTML
<!doctype html>
<html lang="zh-Hant">
<head>
  <meta charset="utf-8">
  <meta name="viewport" content="width=device-width,initial-scale=1">
  <meta name="description" content="《紐約新醫革命》完整導讀：曼哈頓的公立醫院、急診與美國醫療安全網。">
  <title>完整導讀｜紐約新醫革命</title>
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+TC:wght@400;500;700;900&family=Playfair+Display:ital,wght@0,600;0,800;1,600&display=swap" rel="stylesheet">
  <style>
    :root{--ink:#123440;--rust:#9d4033;--paper:#f9f8f4;--mist:#e7f0ef;--line:#c8d5d3;--serif:"Playfair Display","Noto Serif TC",serif;--sans:"Noto Sans TC",sans-serif}*{box-sizing:border-box}body{margin:0;background:var(--paper);color:var(--ink);font:400 17px/1.95 var(--sans)}a{color:var(--rust);text-underline-offset:.18em}.mast{background:#08242e;color:#fff;padding:19px max(22px,calc((100vw - 1060px)/2));display:flex;justify-content:space-between;gap:20px;align-items:center}.mast a{color:#fff;text-decoration:none;font-weight:700}.mast small{color:#c9d8d5}main{max-width:860px;margin:auto;padding:70px 24px 100px}.eyebrow{letter-spacing:.13em;color:var(--rust);font-size:.75rem;font-weight:700}.masthead{border-bottom:1px solid var(--line);padding-bottom:34px;margin-bottom:38px}h1{font:800 clamp(2.7rem,6vw,5rem)/1.12 var(--serif);letter-spacing:-.05em;margin:.4rem 0 1rem}h1 i{display:block;color:var(--rust);font-size:.54em}.deck{font-size:1.28rem;line-height:1.65;margin:0;max-width:700px}.notice{background:var(--mist);border-left:4px solid var(--rust);padding:15px 18px;font-size:.94rem;margin:28px 0 0}h2{font:800 clamp(2rem,4vw,3.1rem)/1.2 var(--serif);letter-spacing:-.045em;margin:78px 0 26px;padding-top:5px;border-top:1px solid var(--line)}h3{font:700 1.28rem/1.5 var(--sans);margin:44px 0 10px;color:#174957}.season{color:var(--ink)}.season span{color:var(--rust);margin-right:18px}p{margin:0 0 17px}.caption{font-size:.82rem;line-height:1.65;color:#567077}.english{font-family:var(--serif);background:#f1e5d5;padding:19px 22px;border-left:4px solid #bc8652}.citation{font-size:.76em;text-decoration:none;margin-left:2px}aside{background:var(--mist);padding:18px 21px;margin:25px 0;font-size:.94rem;line-height:1.8}table{max-width:100%}.sources{margin-top:84px;padding-top:10px;border-top:3px solid var(--ink)}.sources h2{border:0;margin-top:22px}.sources ol{padding-left:1.5rem}.sources li{padding-left:.35rem;margin:.7rem 0;font-size:.89rem;line-height:1.65}.pdf-link{display:inline-block;background:var(--rust);color:#fff;padding:10px 15px;text-decoration:none;font-size:.9rem;font-weight:700;margin-top:10px}@media(max-width:600px){body{font-size:16px}.mast{display:block}.mast small{display:block;margin-top:5px}main{padding:48px 19px 70px}h2{margin-top:58px}.deck{font-size:1.14rem}}
  </style>
</head>
<body>
  <header class="mast"><a href="index.html">劇中所見｜紐約新醫革命</a><small>完整導讀</small></header>
  <main>
    <header class="masthead"><p class="eyebrow">劇中所見　｜　紐約・美國</p><h1>紐約新醫革命 <i>New Amsterdam</i></h1><p class="deck">曼哈頓的公立醫院、急診與美國醫療安全網</p><p class="notice">本頁將原始 PDF 的文章、人物、制度比較、英文練習與資料來源逐段轉寫為網頁。原始版也保留供核對與列印。</p><a class="pdf-link" href="assets/new-amsterdam-guide.pdf" target="_blank" rel="noreferrer">開啟原始 PDF</a></header>
    <article>
#{paragraphs.join("\n")}
    </article>
    <section class="sources" id="sources"><h2>資料與圖像來源</h2><ol>
#{sources.map { |number, url, label| %(<li id="source-#{number}"><a href="#{CGI.escapeHTML(url)}" target="_blank" rel="noreferrer">[#{number}] #{CGI.escapeHTML(label)}</a></li>) }.join("\n")}
    </ol></section>
  </main>
</body>
</html>
HTML

File.write("complete-guide.html", html)
