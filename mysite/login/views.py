from django.shortcuts import render

from django.http import HttpResponse

def index(request):
    return HttpResponse("index")

def login(request):
    return render(request,'login.html')
