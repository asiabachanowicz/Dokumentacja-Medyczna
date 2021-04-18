from django.shortcuts import render
from login.models import Pacjent

from django.http import HttpResponse

def index(request):
    return render(request,"index.html")

def login(request):
    if request.method == 'POST':
        Pacjent.objects
        login = Pacjent(login="test")
        patient = Pacjent.objects.all().filter(login=request.POST["login"], haslo=request.POST['password'])
        print(patient)
        if patient.exists():
            print("zalogowano pacjenta")
            return render(request, 'patient.html')
        else:
            print("nie udalo sie zalogowac pacjenta")
    return render(request,'login.html')

def register(request):
    if request.method == 'POST':
        name = request.POST['name']
        password = request.POST['password']
        surname = request.POST['surname']
        address = request.POST['address']
        date_birth = request.POST['birth_date']
        print(name, password)
        if request.POST.get('women', True):
            plec="kobieta"
        if request.POST.get('men', True):
            plec="mezczyzna"
        patient = Pacjent.objects.create(haslo=password, login=name, nazwisko=surname, adres=address, plec=plec, data_ur=date_birth)
        print(patient)
        patient.save()
    return render(request,'register.html')

def patient(request):
    return render(request, 'patient.html')

