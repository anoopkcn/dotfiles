---
tags: reference
---
# {{title}}

{{bibliography}}

{% if abstractNote %}

### Abstract
{{abstractNote}}

{% endif %}

### Annotations

{% for annotation in annotations %}
{% if annotation.imageRelativePath %}
> <mark style="background-color: {{annotation.color}};color: black">Highlight</mark> 
> ![[{{annotation.imageRelativePath}}]] 
> [Page {{annotation.page}}](zotero://open-pdf/library/items/{{annotation.attachment.itemKey}}?page={{annotation.pageLabel}}&annotation={{annotation.id}})
{% endif %}
{% if annotation.annotatedText %}
> <mark style="background-color: {{annotation.color}};color: black">Highlight</mark> 
> {{annotation.annotatedText}}
> [Page {{annotation.page}}](zotero://open-pdf/library/items/{{annotation.attachment.itemKey}}?page={{annotation.pageLabel}}&annotation={{annotation.id}})
{% endif %}
{% if annotation.comment %}
> <mark style="background-color: {{annotation.color}};color: black">Comment</mark>
> {{annotation.comment}}
> [Page {{annotation.page}}](zotero://open-pdf/library/items/{{annotation.attachment.itemKey}}?page={{annotation.pageLabel}}&annotation={{annotation.id}})
{% endif %}
{% endfor %}