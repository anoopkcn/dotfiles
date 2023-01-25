---
tags: fleeting
created: <% tp.file.creation_date() %>
filename: <% tp.file.title %>
---
<% await tp.file.move("/Fleeting/"+tp.file.title) %>
# <% tp.file.title %>


<% tp.file.cursor(0) %>
