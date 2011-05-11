from django.conf import settings
from BeautifulSoup import BeautifulSoup,Tag
from urlparse import urlparse,urlunsplit

def insert_title(src,dest):
    if src.html.head and src.html.head.title:
        title = src.html.head.title
        dest.html.head.title.replaceWith(title)

def promote(tag_name, must_have, keys = None):
    tag_template = dict([(attr_name, True) for attr_name in must_have])
    if keys is None:
        keys = must_have

    def tag_fingerprint(t):
        return [t[attr_name] for attr_name in keys if attr_name in t].sort

    def move(src,dest):
        in_template = [tag_fingerprint(t) for t in dest.findAll(tag_name, tag_template)]
        new_nodes = [t for t in src.findAll(tag_name, tag_template) if tag_fingerprint(t) not in in_template]
        for node in new_nodes:
            dest.html.head.append(node)
    return move

def promote_nav(src,dest):
    header = dest.find("div",{"id":"container"}) 
    nav = src.find("div",{"id":"promoted-nav"})
    if nav and header:
        header.insert(2,nav)

def insert_body(src,dest):
    if src.find("article") and dest.find("article"):
        body = src.find("article")
        dest.find("article").replaceWith(body)
    elif src.find("body") and dest.find("article"):
        body = src.find("body")
        article = Tag(dest, "article")
        article.insert(0,body)
        dest.find("article").replaceWith(article)

class SlimmerMiddleware(object):

    def template(self,name):
        f = open("%s/%s.html" % (settings.TEMPLATE_PATH,name))
        return f.read()

    def not_found(self,request,response):
        return self.process_error("404")

    def error(self,request,response):
        return self.process_error("500")

    def process_response(self, request, response):
        
        if 'text/html' not in response['Content-Type']:
            return response
                
        if request.path.find('/admin') == 0:
            return response

        responses = { 200: self.skin,
                      404: self.not_found,
                      500: self.error 
                    }
        
        if settings.DEBUG:
           del responses[500]

        if response.status_code in responses:
            response.content = responses[response.status_code](request,response)

        return response

    def skin(self,request,response):
        content = response.content

        processors = [
                insert_title,
                promote('script',['src']),
                promote('link',  ['href']),
                promote('meta',  ['name', 'content'], keys = ['name', 'content', 'http-equiv']),
                promote_nav,
                insert_body,
        ]

        return self.process(processors,content,self.template('wrapper'))

    def process_error(self,template):
        return self.process([ insert_title ],"<html></html>",self.template(template))

    def process(self,processors,content,template):
        BeautifulSoup.NESTABLE_TAGS['p'] = []
        src_soup  = BeautifulSoup(content)
        dest_soup = BeautifulSoup(template)

        for p in processors:
            p(src_soup,dest_soup)

        return str(dest_soup)


