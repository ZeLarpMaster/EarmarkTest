defmodule EarmarkTestWeb.PageController do
  use EarmarkTestWeb, :controller
  import Phoenix.HTML

  @markdown """
  This text is before the code and here is a script tag: <script>alert(1);</script>
  ```html
  <script>alert("No XSS, but not looking good");</script>
  ```
  This is displayed after the code
  """

  def index(conn, _params) do
    conn
    |> assign(:markdowns,
      markdown: markdown(),
      expected: expected(),
      noescape: noescape(),
      noescape_raw: noescape_raw(),
      escaped: escaped(),
      escaped_raw: escaped_raw()
    )
    |> render("index.html")
  end

  defp markdown do
    @markdown
    |> String.split("\n")
    |> Enum.map(&safe_to_string(html_escape(&1)))
    |> Enum.join("<br/>")
    |> raw()
  end

  defp expected do
    ~E"""
    <p>This text is before the code and here is a script tag: &lt;script&gt;alert(1);&lt;/script&gt;</p>
    <pre><code class="html">&lt;script&gt;alert(&quot;No XSS, but not looking good&quot;);&lt;/script&gt;</code></pre>
    <p>This is displayed after the code</p>
    """
  end

  defp noescape, do: @markdown |> parse()
  defp noescape_raw, do: @markdown |> parse() |> raw()
  defp escaped, do: @markdown |> html_escape() |> safe_to_string() |> parse()
  defp escaped_raw, do: @markdown |> html_escape() |> safe_to_string() |> parse() |> raw()

  defp parse(markdown) do
    Earmark.as_html!(markdown, smartypants: false)
  end
end
