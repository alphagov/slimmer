from django.conf import settings
from BeautifulSoup import BeautifulSoup
from urlparse import urlparse

def insert_title(src,dest):
    if src.html.head and src.html.head.title:
        title = src.html.head.title
        dest.html.head.title.replaceWith(title)

def promote(type,tag):
    def move(src,dest):
        in_template = [t[tag] for t in dest.findAll(type,{tag:True})]
        new_nodes = [t for t in src.findAll(type,{tag:True}) if t[tag] not in in_template]
        for node in new_nodes:
            dest.html.head.append(node)
    return move
    
def insert_body(src,dest):
    if src.find("article") and dest.find("article"):
        body = src.find("article")
        dest.find("article").replaceWith(body)

class SlimmerMiddleware(object):

    def template(self,name):
        f = open("%s/%s.html" % (settings.TEMPLATE_PATH,name))
        return f.read()

    def redirect(self,request,response):
        location = urlparse(response['Location'])
        if 'alphagov.co.uk' in location.host:
            location.host = request.host
            location.port = request.port
            response['Location'] = location.get_url()
        return response

    def not_found(self,request,response):
        return self.process_error("404")

    def error(self,request,response):
        return self.process_error("500")

    def process_response(self, request, response):
        
        if 'text/html' not in response['Content-Type']:
            return response
        
        responses = { 200: self.skin,
                      301: self.redirect,
                      302: self.redirect,
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
                promote("script","src"),
                promote("link","href"),
                insert_body
        ]

        return self.process(processors,content,self.template("wrapper"))

    def process_error(self,template):
        return self.process([ insert_title ],"<html></html>",self.template(template))

    def process(self,processors,content,template):
        src_soup  = BeautifulSoup(content)
        dest_soup = BeautifulSoup(template)
   
        for p in processors:
            p(src_soup,dest_soup)

        return dest_soup.prettify()


