from django.http import HttpResponse
from django.shortcuts import render

from visits.models import PageVisit

def home_page_view(request, *args, **kwargs):
  queryset = PageVisit.objects.filter(path=request.path)
  total = PageVisit.objects.all()
  PageVisit.objects.create(path=request.path)
  return render(request, "home.html", {
    "title": "Hello World!",
    "content": "Welcome to the home page. Page visits: " + str(queryset.count()) + " Total visits: " + str(total.count())
  })
