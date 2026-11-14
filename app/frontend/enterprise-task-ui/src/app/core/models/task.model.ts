export interface Task {id:number;title:string;description:string;status:string;priority:number;createdAt:string;updatedAt?:string;userId:number;userName:string;userEmail:string;}
export interface CreateTask {title:string;description:string;priority:number;userId:number;}
