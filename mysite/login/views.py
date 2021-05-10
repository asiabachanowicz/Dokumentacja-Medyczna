from django.shortcuts import render, redirect
from django.http import JsonResponse
from .models import Pacjent
from .models import Lekarz

from django.core import serializers
from django.views.generic import ListView
import json

from django.http import HttpResponse

def index(request):
    return render(request,"index.html")

def patientSite(request):
    patient_name = (request.GET["id"]).split("-")[0]
    patient_surname = (request.GET["id"]).split("-")[1]
    print(patient_name)
    print(patient_surname)
    patient1 = Pacjent.objects.all().filter(imie=patient_name).filter(nazwisko=patient_surname)
    print(patient1)
    return render(request, "patientSite.html", {"pac": patient1})

def loginPatient(request):
    if request.method == 'POST':
        Pacjent.objects
        patient = Pacjent.objects.all().filter(login=request.POST["login"], haslo=request.POST['password'])
        print(patient)
        if patient.exists():
            print("zalogowano pacjenta")
            return render(request, 'patient.html', {"pac": patient})
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
        peselP = request.POST['peselP']
        date_birth = request.POST['birth_date']
        print(name, password)
        sex = request.POST['sex']
        if sex == 'women':
            plec="kobieta"
        if sex == 'men':
            plec = "mezczyzna"

        patient = Pacjent.objects.create(haslo=password, login=mail, imie=name, nazwisko=surname, adres=address, pesel=peselP, plec=plec, data_ur=date_birth)
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
    if request.method == 'POST' or request.is_ajax():
        Pacjent.objects
        patient_data = request.POST['text']
        patient1 = Pacjent.objects.all().filter(imie__startswith=patient_data)
        patient2 = Pacjent.objects.all().filter(pesel__startswith=patient_data)
        patient3 = Pacjent.objects.all().filter(nazwisko__startswith=patient_data)
        if patient1.exists():
            print(patient_data)
            print(patient1)
            serialized_qs = serializers.serialize('json', patient1)
            return JsonResponse(serialized_qs, safe=False)
        elif patient2.exists():
            print(patient_data)
            print(patient2)
            serialized_qs = serializers.serialize('json', patient2)
            return JsonResponse(serialized_qs, safe=False)
        elif patient3.exists():
            print(patient_data)
            print(patient3)
            serialized_qs = serializers.serialize('json', patient3)
            return JsonResponse(serialized_qs, safe=False)
        patients = Pacjent.objects.all().filter(nazwisko__startswith=patient_data)
        if patients.exists():
            print(patient_data)
            print(patients)
            return HttpResponse(patients)

    pac = Pacjent.objects.all()

    return render(request,"doctor.html", {'pac':pac})