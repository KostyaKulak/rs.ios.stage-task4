import Foundation

final class CallStation {
    var callStationUsers: Set<User> = Set()
    var stationCalls: [Call] = []
}

extension CallStation: Station {
    func users() -> [User] {
        Array(callStationUsers)
    }

    func add(user: User) {
        callStationUsers.insert(user)
    }

    func remove(user: User) {
        callStationUsers.remove(user)
    }

    func execute(action: CallAction) -> CallID? {
        switch action {
        case .start(from: let from, to: let to):
            return executeStart(from: from, to: to)
        case .answer(from: let incomingUser):
            return executeAnswer(from: incomingUser)
        case .end(from: let user):
            return executeEnd(from: user)
        }
    }

    func calls() -> [Call] {
        stationCalls
    }

    func calls(user: User) -> [Call] {
        let calls = stationCalls.filter { call in
            call.incomingUser.id == user.id || call.outgoingUser.id == user.id
        }
        return calls
    }

    func call(id: CallID) -> Call? {
        let myCall = stationCalls.filter { call in
            call.id == id
        }
        return myCall.first ?? nil
    }

    func currentCall(user: User) -> Call? {
        let call = stationCalls.filter { call in
            (call.incomingUser.id == user.id || call.outgoingUser.id == user.id) &&
                    (call.status == .calling || call.status == .talk)
        }
        return call.first
    }

    private func executeStart(from: User, to: User) -> CallID? {
        if !callStationUsers.contains(from) && !callStationUsers.contains(to) { return nil }

        var callID = CallID()
        while calls().contains(where: { element in element.id == callID }) {
            callID = CallID()
        }

        var callStatus: CallStatus
        if !callStationUsers.contains(from) || !callStationUsers.contains(to) {
            callStatus = .ended(reason: .error)
        } else if calls(user: to).filter({ $0.status == .talk || $0.status == .calling }).count > 0 {
            callStatus = .ended(reason: .userBusy)
        } else {
            callStatus = .calling
        }

        stationCalls.append(Call(id: callID, incomingUser: to, outgoingUser: from, status: callStatus))

        return callID
    }

    private func executeAnswer(from: User) -> CallID? {
        guard let call = stationCalls.filter({ $0.incomingUser == from && $0.status == .calling }).first else { return nil }

        var someoneCrashed = false
        for user in [call.incomingUser, call.outgoingUser] {
            if !callStationUsers.contains(user) {
                abortAllCalls(forUser: user)
                someoneCrashed = true
            }
        }
        guard !someoneCrashed else { return nil }

        changeStatus(for: call, to: .talk)
        return call.id
    }

    private func abortAllCalls(forUser: User) {
        for brokenCall in calls(user: forUser) {
            changeStatus(for: brokenCall, to: .ended(reason: .error))
        }
    }

    private func executeEnd(from: User) -> CallID? {
        guard let call = calls(user: from).filter({ $0.status == .talk ||  $0.status == .calling }).first else { return nil }

        let endReason: CallEndReason = call.status == .talk ? .end : .cancel
        changeStatus(for: call, to: .ended(reason: endReason))
        return call.id
    }

    private func changeStatus(for call: Call, to status: CallStatus) {
        stationCalls = stationCalls.filter { $0.id != call.id }
        stationCalls.append(Call(id: call.id, incomingUser: call.incomingUser, outgoingUser: call.outgoingUser, status: status))
    }
}
