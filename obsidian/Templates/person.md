---
tags: person
created: <% tp.file.creation_date() %>
email:
image:
title:
company: 
location: 
aliases:
date_last_spoken:
follow_up:
---
<% await tp.file.move("/Collection/People/"+tp.file.title) %>
# [[<% tp.file.title %>]]
email:
image:


## Meetings


```dataview
table file.cday as Created, summary as "Summary" 
from [[<%tp.file.title %>]] and -"Templates"
where contains(tags, "meeting")
sort date desc
```
