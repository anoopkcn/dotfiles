---
tags: record
created: <% tp.file.creation_date() %>
filename: <% tp.file.title %>
---
# <% tp.user.format_title(tp) %>

<% await tp.file.move("/Record/"+tp.file.title) %>
<% tp.file.cursor(0) %>
