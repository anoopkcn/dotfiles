---
tags: reference
created: <% tp.file.creation_date() %>
filename: &<% tp.file.title %>
author: 
year: 
---
<% await tp.file.move("/Reference/&"+tp.file.title) %>
<% tp.file.cursor(0) %>