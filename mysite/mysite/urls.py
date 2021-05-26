"""mysite URL Configuration

The `urlpatterns` list routes URLs to views. For more information please see:
    https://docs.djangoproject.com/en/3.1/topics/http/urls/
Examples:
Function views
    1. Add an import:  from my_app import views
    2. Add a URL to urlpatterns:  path('', views.home, name='home')
Class-based views
    1. Add an import:  from other_app.views import Home
    2. Add a URL to urlpatterns:  path('', Home.as_view(), name='home')
Including another URLconf
    1. Import the include() function: from django.urls import include, path
    2. Add a URL to urlpatterns:  path('blog/', include('blog.urls'))
"""

from django.conf.urls import url
from django.urls import path
from login.views import addDocument, Udar_mozgu, Stwardnienie_rozsiane,Padaczka,Choroba_Parkinsona,Choroba_Alzheimera, DiagnoseSiteNew, diagnose, loginPatient, loginDoctor, registerPatient, registerDoctor, patient, index, doctor, patientSite, badaniaMri, badaniaLab, diagnozy, report

urlpatterns = [
    url('DiagnoseSiteNew/', DiagnoseSiteNew, name="DiagnoseSiteNew"),
    url('Udar_mozgu/', Udar_mozgu, name="Udar_mozgu"),
    url('Padaczka/', Padaczka, name="Padaczka"),
    url('Choroba_Parkinsona/', Choroba_Parkinsona, name="Choroba_Parkinsona"),
    url('Choroba_Alzheimera/', Choroba_Alzheimera, name="Choroba_Alzheimera"),
    url('Stwardnienie_rozsiane/', Stwardnienie_rozsiane, name="Stwardnienie_rozsiane"),

    #url('DiagnoseSite/', DiagnoseSite, name="DiagnoseSite"),
    url('loginPatient/', loginPatient, name="loginPatient"),
    url('loginDoctor/', loginDoctor, name="loginDoctor"),
    url('registerPatient/', registerPatient, name="registerPatient"),
    url('registerDoctor/', registerDoctor, name="registerDoctor"),
    url('patient/', patient, name="patient"),
    url('doctor/', doctor, name="doctor"),
    url('patient-site/', patientSite, name='patientSite'),
    url('report/', report, name="report"),
    url('diagnose/', diagnose, name="diagnose"),
    url('addDocument', addDocument, name="addDocument"),
    url('data/badania_lab', badaniaLab, name="badaniaLab"),
    url('/data/badania_mri', badaniaMri, name="badaniaMri"),
    url('data/diagnozy', diagnozy, name="diagnozy"),
    url('', index, name="index"),
    path('doctor/', doctor, name='doctor'),
]
