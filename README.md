# M/M/1/K LIFO

Simulació d'una cua amb un servidor i aforament màxim, K. Es serviran/rebutjaran un total de n clients.
Els clients arribaran i seran servits d'acord amb una distribució exponencial.

És una cua Last In First Out, és a dir, que es serviran els que estiguin al final de la cua primer. 

## Resultat

Al final en una taula T, es mostrarà de cada client:
* Número de client en ordre d'arribada. 'Num_Costumer' (entre 1 i n)
* Temps d'interarribada. Temps entre l'arribada del client anterior i la del client actual. 'Interarrival_Time'.
* Temps d'arribada. 'Arrival_Time'
* Quin servidor el serveix. 'Server' (entre 1 i s)
* Temps en que es comença a servir. 'Time_Service_Begins'
* Temps en que s'acaba de servir. 'Time_Service_Ends'
* Temps que ha tardat en servir-se. 'Service_Time'
* Temps que ha estat a la cua. 'Wq'
* Temps total al sistema. 'W'
* Temps de descans del servidor. 'Idle_Time'

Vector fora amb l'índex de tots els clients rebutjats.
