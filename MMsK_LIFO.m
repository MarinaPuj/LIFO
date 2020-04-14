close all
clear all
clc
format long;

%% Simulaci� Cua M/M/s/K LIFO
lambda=5; % 4 camions per hora = 1 cami� cada 15 mins
mu=10; % 6 camions per hora = 1 cami� cada 10 mins

s=1; % n� de servidors
K=4; % aforament m�xim sistema
n=20; % n� de camions a simular


for i=1:n
t(i,1)=i;
zero(i,1)=0;
end

noms={'Num_Costumer','Interarrival_time','Arrival_Time','Service_Time','Time_Service_Begins','Wq','Time_Service_Ends','W','Idle_Time'};
T=table(t,zero,zero,zero,zero,zero,zero,zero,zero,'VariableNames', noms);



for i=1:n
    %exprnd: Genera n�meros aleatoris a partir d'una distribuci�
    %exponencial amb lambda = par�metre mig
    T.Interarrival_time(i)=exprnd(lambda); %Temps d'arribada de cada client. Interarrival time (min)
    T.Arrival_Time(i)=sum(T.Interarrival_time); %Temps acumulat d'arribada dels clients. C1
    T.Service_Time(i)=exprnd(mu); %Generar temps de servei de i dins de la distribuci� exponencial de mitjana mu
end

for i=1:s %Clients sense cua.
    T.Service_Time(i)=exprnd(mu);  %Genera temps de servei de cada client seguint la distribuci� mu. Service time (min)
    T.Time_Service_Begins(i)= T.Arrival_Time(i);               % temps servei comen�a (clock). C2
    T.Time_Service_Ends(i)=T.Time_Service_Begins(i)+T.Service_Time(i);  % temps servei acaba (clock). C3
    T.W(i)=T.Time_Service_Ends(i)-T.Arrival_Time(i);      % time costumers spend in system. W. C5
    T.Wq(i)=T.Time_Service_Begins(i)-T.Arrival_Time(i);      % waiting time in queue. C4
    
    if i-1==0
        T.Idle_Time(i)=T.Arrival_Time(i);  %durada de descans del servidor. C6
    end
    entr(i)=i;
end


M=1;  %M �ltim client ates.
Q=0;  %Q n�mero clients a la cua
queue(1)=0;  %queue: �ndex dels clients a la cua
q=1; %�ndex de queue
f=1; %�ndex de fora
fora(f)=0;  %fora: �ndex dels clients que marxen


finaltime=T.Time_Service_Ends(M); %temps en el que ha acabat l'�ltim client servit
entren=0; %n�mero de cotxes que entren
entrens=length(entr);

%Que segueixi el loop mentre la suma del nombre de clients que entren 
%i els que marxen sense entrar (fora) sigui menor que n i si M �s m�s petit
%o igual a n (redundant).

while (entren+length(fora)<n && M<=n) 
    entren=entren+1; %Entra un nou client
    a=0; 
    if(q==0)q=1;end
    %disp(M);
    %disp(queue);
    %disp(fora);
    %Calcular el n�mero de clients que han arribat mentre M era servit
    for t=M+1:n  %Per als clients que arriben despr�s de M
        if(T.Time_Service_Ends(M)>=T.Arrival_Time(t)) %Si el temps final de M �s m�s gran que el temps d'arribada d'un altre client, aquest ha arribat mentre M estava sent servit -> a la cua
            if(T.Time_Service_Begins(t)==0) %Si el temps de servei del client posterior es 0 -> encara no ha estat servit
                queue(q)=T.Num_Costumer(t); %Guardar l'�ndex del client a la queue.
                q=q+1;
                a=a+1; %n�mero de clients que es fiquen a la cua mentre M era servit;
            end
        end
    end
    
   %Mirar quins clients de la queue ja havien marxat en una iteraci� anterior, el seu index est� al vector fora()
   if(sum(fora)~=0) %si fora no es 0 -> alg� ha marxat
    for tt=1:length(fora) %iterem al llarg de fora
       for t=1:length(queue) %iterem al llarg de la queue
            if (fora(tt)==queue(t)) %Si el numero de client de fora i de la queue coincideix.
                queue(t)=0; %El client que ja havia marxat ara t� index 0 a la queue
                q=q-1;
                a=a-1;   %Si alg� estava al vector fora, no ha entrat a la cua mentre M era servit
            end
       end
    end
   end

    %Eliminar els clients que ja havien marxat abans. (els que tenen �ndex 0 a la queue)
   
    k=find(~queue); %vector amb els �ndexs dels 0s de la queue
    ii=length(k);
    while (ii>=1)  
           queue(k(ii))=[];
           ii=ii-1;
    end
    
    %Eliminar els clients que han arribat mentre M era servit i no cabien
    %Nombre de clients m�xim a la cua: N-1.
    q2=length(queue);
    Q=Q+a;
    if (q2>=K) %Si la llargada de la cua �s major que N-1 
        while q2>=K  % Per a tots els que no caben a la cua:  
            fora(f)=queue(q2); %els fiquem al vector fora
            f=f+1;
            Q=Q-1;
            queue(q2)=0;  %els traiem de la cua
            a=a-1;      %No ha entrat a la cua mentre M era servit
            q2=q2-1;
        end
        q=K-1;  %la mida m�xima de la cua
    else
        q=q2; 
    end
    
    if(q==0)q=1;end %Calen indexs positius

    %Mentre M era at�s...
    
    %CAS 1. a>0. Ha arribat alg�n client -> l'�ltim en arribar ser� el primer en ser at�s
    %CAS 2. Q>0. No ha arribat cap client nou, per� a la cua hi ha alg� esperant
    %Podem ajuntar cas 1 i cas 2 perque ambdos depenen de l'�ltim client de la cua. 
    if (a>0 || Q>0) 
        p=queue(q); %�ltim client de la cua
        T.Time_Service_Begins(p)=T.Time_Service_Ends(M);  %Temps final de l'�ltim de la cua = temps final del anterior client servit
        T.Time_Service_Ends(p)=T.Time_Service_Ends(M)+T.Service_Time(p);
        T.Idle_Time(p)=0; 
        finaltime=T.Time_Service_Ends(p);  
        M=p; 
        Q=Q-1; 
        queue(q)=0; %treiem el client servit de la cua
    
    %CAS 3 No ha arribat cap client i no hi ha ning� a la cua.
    elseif(M<n && T.Time_Service_Begins(M+1)==0) %Assegurar-nos que M+1 no ha passat per la iteraci� abans i que M+1 existeix
        T.Time_Service_Begins(M+1)=T.Arrival_Time(M+1); %El client ser� at�s tant bon punt arribi.
        T.Time_Service_Ends(M+1)=T.Arrival_Time(M+1)+T.Service_Time(M+1);
        T.Idle_Time(M+1)=T.Time_Service_Begins(M+1)-finaltime; %Entre el client anterior i aquest la m�quina descansa
        finaltime=T.Time_Service_Ends(M+1);
        M=M+1;
        Q=0;
    else %Si no s'ha complert ni el CAS 1 ni el 2 ni el 3, no ha entrat cap client. Entrarem en aquet else, quan s'ha acabat la cua i es busca qui es el seg�ent (Quan no hi ha cua i el client M+1 ja ha entrat  T.Time_Service_Begins(M+1)!=0)
        %Mirem el seg�ent a la llista.
        M=M+1;
        entren=entren-1; %No ha entrat cap client
        %Comprovar que el seg�ent a la llista no est� al vector fora ni ha entrat ja.
        al=0;
        if(M<=n)
         g=0;
        else
         g=1;
        end
        if(sum(fora)~=0) %Si hi ha algun cami� a la llista de fora (alg�n no ha pogut entrar)
            while(g==0) %Seguir fent iteracions fins que no trobem un client que NI estigui a fora NI hagi entrat ja.
                for gg=1:length(fora) %Mirar al llarg del vector fora 
                    if(fora(gg)==M) %Si la nova M coincideix amb un dels valors de fora g=longitud de fora-1
                        g=0;
                    else 
                        g=g+1;  %Si no coincideix amb cap valor de fora g=longitud de fora
                    end
                end
                %Si g NO es igual a la longitud de fora -> El valor M est� a fora 
                %Si el valor del temps de comen�ar el servei de M NO �s 0 -> M ja ha estat servit abans  
                % Si M est� a fora o ja ha estat servit abans, cal comprovar-ho tot per la seg�ent M -> M=M+1 i g=0 (seguir al loop);
                if(g~=length(fora)||T.Time_Service_Begins(M)~=0) 
                    if(M>=n) %Si M �s m�s gran o igual a n -> sortir del loop
                     g=1; 
                     al=0;
                    else
                     al=1;
                     M=M+1;
                     g=0;
                    end
                end
            end
        end
        %Si al=1 algunes de les M que hem comprovat estaven fora/ja havien entrat, per tant cal centrar-nos en la M actual, per fer-ho direm que l'�ltim client servit ha estat M-1
        if(al==1)
            M=M-1; 
        end
    end
end

%Calcular temps de cua i de servei de tots els clients que han entrat al sistema
for i=s+1:n 
        if(T.Time_Service_Begins(i)~=0)
        T.W(i)=T.Time_Service_Ends(i)-T.Arrival_Time(i);
        T.Wq(i)=T.Time_Service_Begins(i)-T.Arrival_Time(i);
        end
end

T = movevars(T, 'Time_Service_Begins', 'Before', 'Service_Time');
T = movevars(T, 'Time_Service_Ends', 'Before', 'Service_Time');
%T = movevars(T, 'Interarrival_time', 'Before', 'Wq');

%% Percentatge de camions que arriba i ha de marxar:

Pfora = length(fora)/n; %Percentatge de camions que arriba i ha de marxar.
Error_absolut=abs(0.078-Pfora);
%Error_relatiu=Error_absolut/0.078;

disp(Pfora);