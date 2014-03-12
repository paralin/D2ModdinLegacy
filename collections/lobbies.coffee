
## LOBBIES
# PUBLIC
#   - name -> "Nigma's Stream"
#   - hasPassword -> false
#   - isMatchmaking -> false
#   - public -> true
#   - mod -> "fof"
#   - creator -> "Nigma" (IF isMatchmaking == false)
#   - creatorid -> "userid"
#   - radiant -> [{_id: id, name: "Quantum", avatar: "someshit"}]
#   - dire -> same thing
#   - invitedPlayers -> [user ID array]
#   - serverIP -> connection address (cached)
# PRIVATE
#   - mmid -> matchmaking resolution ID
#   - status -> 0 = waiting for users, 1 = finding server, 2 = playing, 3 = done
#   - requiresFullLobby -> If admin, false. Otherwise, true.
#   - serverStatus -> 0 = server not found, 1= in server queue, 2 = server reserved
#   - devMode -> false (set -condebug and -dev) 
@lobbies = new Meteor.Collection "lobbies"
