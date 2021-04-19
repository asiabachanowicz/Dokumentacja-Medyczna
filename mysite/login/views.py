from django.shortcuts import render, redirect
from .models import Pacjent
from .models import Lekarz
from django.views.generic import ListView

from django.http import HttpResponse

def index(request):
    return render(request,"index.html")

def loginPatient(request):
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
    return render(request,'loginPatient.html')

def registerPatient(request):
    if request.method == 'POST':
        mail = request.POST['login']
        name = request.POST['name']
        password = request.POST['password']
        surname = request.POST['surname']
        address = request.POST['address']
        date_birth = request.POST['birth_date']
        print(name, password)
        sex = request.POST['sex']
        if sex == 'women':
            plec="kobieta"
        if sex == 'men':
            plec = "mezczyzna"

        patient = Pacjent.objects.create(haslo=password, login=mail, imie=name, nazwisko=surname, adres=address, plec=plec, data_ur=date_birth)
        print(patient)
        patient.save()
        return render(request, 'loginPatient.html')
    return render(request,'registerPatient.html')

def patient(request):
    return render(request, 'patient.html')


def loginDoctor(request):
    if request.method == 'POST':
        Lekarz.objects
        login = Lekarz(login="test")
        doctors = Lekarz.objects.all().filter(login=request.POST["login"], haslo=request.POST['password'])
        print(doctors)
        if doctors.exists():
            print("zalogowano lekarza")
            return redirect('doctor')
        else:
            print("nie udalo sie zalogowac lekarza")
    return render(request,'loginDoctor.html')

def registerDoctor(request):
    if request.method == 'POST':
        mail = request.POST['login']
        password = request.POST['password']
        name = request.POST['name']
        surname = request.POST['surname']
        tel_number = request.POST['tel_number']
        print(name, password)

        doctor = Lekarz.objects.create(haslo=password, login=mail, imie=name, nazwisko=surname, nr_telefonu=tel_number)
        print(doctor)
        doctor.save()
        return render(request, 'loginDoctor.html')
    return render(request,'registerDoctor.html')

def doctor(request):
    print("doctor")
    if request.method == 'POST' or request.is_ajax():
        print("tak")
        print(request.POST['text'])

    #wyswiettlenie loginow w konsoli
    for e in Pacjent.objects.all():
        print(e.login)

    #wyswietlenie obiektow w html
    pac = Pacjent.objects.all()

    return render(request,"doctor.html", {'pac':pac})




