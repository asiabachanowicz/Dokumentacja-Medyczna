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
from login.views import loginPatient, loginDoctor, registerPatient, registerDoctor, patient, doctor, index

urlpatterns = [
    url('loginPatient/', loginPatient, name="loginPatient"),
    url('loginDoctor/', loginDoctor, name="loginDoctor"),
    url('registerPatient/', registerPatient, name="registerPatient"),
    url('registerDoctor/', registerDoctor, name="registerDoctor"),
    url('patient/', patient, name="patient"),
    url('doctor/', doctor, name="doctor"),
    url('', index, name="index")
]
