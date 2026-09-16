# Dakkana mobile

Flutter mobile application placeholder for the first implementation phase.

Architecture target:
- presentation/
- application/
- domain/
- data/local/
- data/remote/
- data/repositories/
- core/

The mobile app must remain usable when the network is unavailable. SQLite transactions and the outbox queue are part of the same local transaction for every financial write.
