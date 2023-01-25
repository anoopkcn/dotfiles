---
tags: info
created: <% tp.file.creation_date() %>
filename: <% tp.file.title %>
---
<% await tp.file.move("/Collection/Info/"+tp.file.title) %>
# <% tp.user.format_title(tp) %>


<% tp.file.cursor(0) %>
