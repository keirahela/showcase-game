export type Direction = "Left"|"Right"|"Front"|"Back" -- For dashes
export type Action = "M1"|"M2"|"Critical"|"Block"
export type Special = "Dash"|"Grip"
export type State = "Idle"|"Stunned"|"Ragdoll"|"Attacking"|"Blocking"

export type MaidTask = (() -> ()) | Instance | thread | any | RBXScriptConnection | nil

export type Maid = typeof(setmetatable(
	{} :: {
		Add: <T>(self: Maid, task: T) -> T,
		GiveTask: (self: Maid, task: MaidTask) -> number,
		GivePromise: <T>(self: Maid, promise: T) -> T,
		DoCleaning: (self: Maid) -> (),
		Destroy: (self: Maid) -> (),
		_tasks: { [any]: MaidTask },
		[string | number | MaidTask]: any,
	},
	{}
))

export type CombatServer = {
	["Handler"] : {
		[Player] : {
			State : State,
			CurrentAction : thread?,--task.spawn(Methods.Combat[Action])
			Maid : Maid
		}
	},
	["Methods"] : {
		["Combat"] : {[Action]:(...any)->(...any)},
		["Special"] : {[Special]:(...any)->(...any)}
	},
	["CastWhitelist"] : {BasePart}
}

export type CombatClient = {
	["Input"] : {["Combat"] : { [Action]: Enum.KeyCode} , ["Special"] : {[Special] : Enum.KeyCode} },
	["Actions"] : {["Combat"] : { [Action]: (T...) -> (any)} , ["Special"] : {[Special] : (T...)->(any)} },
	["Cleanup"] : {["Combat"] : { [Action]: (T...) -> (any)} , ["Special"] : {[Special] : (T...)->(any)} },
	["State"] : State,
	["_serviceBag"] : any,
	["Requests"] : {thread},
	["Debounces"] : {
		["Combat"] : {[Action]:thread?},
		["Special"] : {[Special]:thread?}
	},
	["Connections"] : {[Action|Special]: RBXScriptConnection},
	["currentHitString"] : number,
	["currentHitStringReset"] : thread?,
	["changeState"] : (self: CombatClient, newState: State) -> (),
	["StateChanged"] : any?, -- cba typing
	["Cast"] : {[string]:BasePart},
}
return {}